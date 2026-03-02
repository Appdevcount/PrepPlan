data "azurerm_client_config" "current" {}
data "azurerm_key_vault" "vault" {
  name                = "kv-cmk-poc-101010"
  resource_group_name = "tb-rsg-keyvault-poc"
}
resource "random_string" "randomname" {
  length  = 8
  special = false
  upper   = false
}

module "storage" {
  source = "git::ssh://git@ssh.dev.azure.com/v3/eviCoreDev/Reusable%20Code/Azure-GoldenStorage?ref=v2.0.1"

  name = "gmtestsa${random_string.randomname.result}"
  resource_group_name = var.resource_group_name
  location = var.location
  public_network_access_enabled = false
  
  #account_replication_type = "ZRS"

  required_tags = {
    AssetOwner             = "troy.braman@evicore.com"
    CostCenter             = "61700200"
    SecurityReviewID       = "notassigned"
    ServiceNowAS           = "notassigned"
    ServiceNowBA           = "notassigned"

  }

  #optional_tags = var.optional_tags
  optional_tags = {
    AppName                = "Test App"
    Tier                   = "2"
    P2P                    = "RITM1234567"
  }


 required_data_tags = {
    BusinessEntity         = "evicore"
    ComplianceDataCategory = "none"
    DataClassification     = "confidential"
    DataSubjectArea        = "it"
    LineOfBusiness         = "commercial"
 }

  cmk_keyvault                            = {
                                              id                        = data.azurerm_key_vault.vault.id
                                              enable_rbac_authorization = data.azurerm_key_vault.vault.enable_rbac_authorization
                                              cmk_key_name              = "storage-cmk-key"
                                            }   


  storage_diagnostics_settings = local.storage_diag
  blob_diagnostics_settings = local.storage_diag
  file_diagnostics_settings = local.storage_diag
  queue_diagnostics_settings = local.storage_diag
  table_diagnostics_settings = local.storage_diag

  private_endpoints = ["blob"]
  pe_subnet_id = local.pe_subnet_id

  enable_ccoe_local_testing               = true 
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                       = "${var.resource_group_name}-log"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  internet_query_enabled     = true
  internet_ingestion_enabled = true
  tags                       = var.required_tags
}

resource "azurerm_application_insights" "appinsights" {

  name                                = "${var.app_service_plan_name}-ai"
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  workspace_id                        = azurerm_log_analytics_workspace.workspace.id
  application_type                    = "web"
  internet_ingestion_enabled          = true
  internet_query_enabled              = true
  local_authentication_disabled       = false
  force_customer_storage_for_profiler = false
  sampling_percentage                 = 0
  tags                                = var.required_tags
}

resource "azurerm_service_plan" "asp" {
  name                         = var.app_service_plan_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  os_type                      = "Linux"
  sku_name                     = local.sku_name
  #maximum_elastic_worker_count = 3 #For Elastic PLans only
  worker_count                 = 3
  per_site_scaling_enabled     = false
  zone_balancing_enabled       = false
  tags                         = var.required_tags
}

module "GoldenLinuxFuncApp" {
    depends_on = [module.storage, azurerm_service_plan.asp]
    source                            = "../../../LinuxFunctionApp"
    #source                            = "git::ssh://git@ssh.dev.azure.com/v3/eviCoreDev/Reusable%20Code/Azure-GoldenAppService//WindowsFunctionApp?ref=evicore_1.0.0"
    providers = {
      azurerm.alarm_funnel_ag_subscription = azurerm.alarm_funnel_ag_subscription
    }
    for_each                          = var.functions_to_create
    name                              = each.key
    resource_group_name               = var.resource_group_name
    location                          = var.location
    environment                       = var.environment
    health_check_path                 = "/api/HealthCheck"
    required_tags                     = var.required_tags
    optional_tags                     = var.optional_tags

    service_plan_id                   = azurerm_service_plan.asp.id
    storage_account_name              = module.storage.storage_account_name
    storage_account_id                = module.storage.storage_account_id   
    application_insights_key          = azurerm_application_insights.appinsights.instrumentation_key
    appinsights_connection_string     = azurerm_application_insights.appinsights.connection_string

    #Scaling
    per_site_scaling_enabled         = true
    app_scale_limit                   = 4
    app_worker_count                  = 1 #If Zone redundancy is enabled in ASP, the worker_count should equal the number of zones in the selected region.
    pre_warmed_instance_count         = 2
    plan_worker_count                 = 3 #On Elastic Plan, the actual minimum number of instances will be autoconfigured for you based on the always ready instances requested by apps in the plan, otherise it will set the current instance count and set the scale out method to Manual.
    runtime_scale_monitoring_enabled  = false # Use only for Elastic Plan.

    #Configuration
    always_on                         = true
    use_32_bit_worker                 = false
    use_python                        = true
    python_version                    = "3.11"
    client_certificate_enabled        = true
    client_certificate_mode           = "Optional"
    sticky_settings_app_setting_names = ["DRYRUN"]
    app_settings                      = {
                                          # User settings
                                          TEST1SETTING = "test1"
                                          TEST2SETTING = "test2"
                                        }  
    allowed_origins                   = ["https://portal.azure.com"]
    
    #Networking
    vnet_route_all_enabled            = true
    virtual_network_subnet_id         = var.virtualnetworksubnetid
    private_endpoint_subnet_id        = local.pe_subnet_id
    
    #Include Monitoring and Alerts
    function_diagnostics_settings   = local.function_diag   
}

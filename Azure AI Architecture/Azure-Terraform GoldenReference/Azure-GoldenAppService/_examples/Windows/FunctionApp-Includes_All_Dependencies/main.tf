provider "azurerm" {
  #subscription_id = "021aa9b2-0000-xxxx-0000-503686e49f00"
  features {}
}

data "azurerm_client_config" "current" {}
data "azurerm_key_vault" "vault" {
  name                = "kv-cmk-poc-101010"
  resource_group_name = "tb-rsg-keyvault-poc"
}

module "storage" {
  source = "git::ssh://git@ssh.dev.azure.com/v3/eviCoreDev/Reusable%20Code/Azure-GoldenStorage?ref=v2.0.0"

  name = "testtbgmfa1000sa"
  resource_group_name = var.resource_group_name
  location = var.location
  public_network_access_enabled = false

  #account_replication_type = "ZRS"
  #allowed_subnet_ids = [var.virtualnetworksubnetid]
required_tags = {
  AssetOwner             = "troy.braman@evicore.com"
  CostCenter             = "61700200"
  SecurityReviewID       = "notassigned"
  ServiceNowAS           = "notassigned"
  ServiceNowBA           = "notassigned"
}
  #optional_tags = var.optional_tags
optional_tags = {
                  MyCustomTag = "TestValue",
                  P2P         = "RITM1234567"
}
required_data_tags = {
  BusinessEntity         = "evicore"
  ComplianceDataCategory = "hipaa:pci"
  DataClassification     = "confidential"
  DataSubjectArea        = "client:customer"
  LineOfBusiness         = "commercial"
}

containers = ["fabackup", "testcontainer-2"]

  #Policy: Storage accounts should use customer-managed key for encryption
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
pe_subnet_id      = local.pe_subnet_id

}

module "GoldenWindowFuncApp" {
    depends_on                        = [ module.storage ]
    source                            = "../../../WindowsFunctionApp"
    name                              = "test-tb-gm-window-os-fa"
    resource_group_name               = var.resource_group_name
    location                          = var.location

    #Add Storage Account


    #Add app_service_plan_name and app_service_plan_sku_name to have the module create ASP
    include_app_service_plan          = true
    app_service_plan_name             = var.app_service_plan_name  
    app_service_plan_sku_name         = "EP1" #When using a Elastic Plan, "Always On" must be False
    #Additional Optional ASP settings
    #plan_maximum_elastic_worker_count = 15 #Only used with Elastic Plan = Maximum Burst
    #plan_worker_count                 = 9 #On Elastic Plan, the actual minimum number of instances will be autoconfigured for you based on the always ready instances requested by apps in the plan, otherise it will set the current instance count and set the scale out method to Manual.
    per_site_scaling_enabled          = true
    #zone_balancing_enabled           = false

    #Add Log Analytics Workspace and App Insights
    include_app_insights              = true

    #Add FMEA Alerts
    include_alerts                    = true

    app_scale_limit                   = 4
    app_worker_count                  = 2
    #elastic_instance_minimum          = 5 # Use only for Elastic Plan.
    pre_warmed_instance_count         = 6
    #runtime_scale_monitoring_enabled  = true # Use only for Elastic Plan.

    always_on                         = false
    use_32_bit_worker                 = false
    use_dotnet                        = true
    dotnet_version                    = "v8.0"
    use_dotnet_isolated_runtime       = true  
    client_certificate_enabled        = true
    client_certificate_mode           = "Optional"
    required_tags                     = var.required_tags
    optional_tags                     = var.optional_tags
    storage_account_access_key        = module.storage.storage_account.primary_access_key
    storage_account_name              = module.storage.storage_account.name
    #Custom Backup
    #storage_account_backup_container_name = "fabackup"
    #storage_account_backup_container_sas = data.azurerm_storage_account_blob_container_sas.containersas.sas

    #storage_uses_managed_identity     = true
    storage_account_id                = module.storage.storage_account_id    
    virtual_network_subnet_id         = var.virtualnetworksubnetid
    private_endpoint_subnet_id        = local.pe_subnet_id
    ip_restriction                    = var.ip_restriction
    scm_ip_restriction                = var.scm_ip_restriction
    allowed_origins                   = ["https://portal.azure.com"]
    sticky_settings_app_setting_names = ["DRYRUN"]
    app_settings                      = {
                                          # User settings
                                          TEST1SETTING = "test1"
                                          TEST2SETTING = "test2"
                                        }
}


provider "azurerm" {
  #subscription_id = "021aa9b2-0000-xxxx-0000-503686e49f00"
  features {}
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

module "Azure-GoldenAppServicePlan" {
  #source             = "git::https://github.sys.cigna.com/cigna/Azure-GoldenAppService/AppServicePlan.git?ref=1.0.0"
  source              = "../../../AppServicePlan"
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  required_tags       = var.required_tags
  sku_name            = local.sku_name
  os_type             = "Linux"
}

module "GoldenLinuxFuncApp" {
    depends_on                        = [ module.storage, azurerm_application_insights.appinsights ]
    source                            = "../../../LinuxFunctionApp"
    name                              = "tb-func-linux-gm-test"
    resource_group_name               = var.resource_group_name
    service_plan_id                   = module.Azure-GoldenAppServicePlan.asp_id
    location                          = var.location
    sku_name                          = local.sku_name
    always_on                         = true
    client_certificate_enabled        = true
    client_certificate_mode           = "Optional"
    required_tags                     = var.required_tags
    optional_tags                     = var.optional_tags
    storage_account_name              = module.storage.storage_account.name
    #storage_account_access_key       = module.storage.storage_account.primary_access_key
    storage_uses_managed_identity     = true
    storage_account_id                = module.storage.storage_account_id    
    virtual_network_subnet_id         = var.virtualnetworksubnetid
    appinsights_connection_string     = azurerm_application_insights.appinsights.connection_string
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

module "storage" {
  source = "git::ssh://git@ssh.dev.azure.com/v3/eviCoreDev/Reusable%20Code/Azure-GoldenStorage?ref=v1.1.0"

  name = "tbgmfasa1234"
  resource_group_name = var.resource_group_name
  location = var.location
  public_network_access_enabled = false

  #account_replication_type = "ZRS"
  #allowed_subnet_ids = [var.virtualnetworksubnetid]
  required_tags = {
    AssetOwner             = "troy.braman@evicore.com"
    BusinessEntity         = "evicore"
    ComplianceDataCategory = "none"
    CostCenter             = "61700200"
    DataClassification     = "confidential"
    DataSubjectArea        = "it"
    LineOfBusiness         = "commercial"
    SecurityReviewID       = "notassigned"
    ServiceNowAS           = "notassigned"
    ServiceNowBA           = "notassigned"
    AppName                = "Test App"
    BusinessOwner          = "troy.braman@evicore.com"
    ITSponsor              = "troy.braman@evicore.com"
    Tier                   = "2"
  }
  #optional_tags = var.optional_tags

  #user_assigned_identity_ids = [azurerm_user_assigned_identity.storage_identity.id]
  enable_customer_managed_key = false
  #storage_enc_keyvault_key_id = azurerm_key_vault_key.cmk.versionless_id

  storage_diagnostics_settings = local.storage_diag
  blob_diagnostics_settings = local.storage_diag
  file_diagnostics_settings = local.storage_diag
  queue_diagnostics_settings = local.storage_diag
  table_diagnostics_settings = local.storage_diag

  private_endpoints = [  {
      subresource_name      = "blob"
  }
  ]
  pe_subnet_id = local.pe_subnet_id
}

/* resource "azurerm_role_assignment" "function_app_strg_role_assignment" {
  depends_on           = [module.GoldenLinuxFuncApp]
  role_definition_name = "Storage Blob Data Contributor"
  scope                = module.storage.storage_account_id
  principal_id         = module.GoldenLinuxFuncApp.app_identity
  principal_type       = "ServicePrincipal"
} */
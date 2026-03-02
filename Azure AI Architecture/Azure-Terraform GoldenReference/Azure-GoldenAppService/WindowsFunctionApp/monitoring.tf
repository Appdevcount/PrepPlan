resource "azurerm_log_analytics_workspace" "workspace" {
  count                      = var.include_app_insights  ? 1 : 0  
  name                       = "${var.app_service_plan_name}-law"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  internet_query_enabled     = true
  internet_ingestion_enabled = true
  tags                       = var.required_tags
}

resource "azurerm_application_insights" "appinsights" {
  depends_on                          = [azurerm_log_analytics_workspace.workspace]  
  count                               = var.include_app_insights ? 1 : 0     
  name                                = "${var.app_service_plan_name}-ai"
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  workspace_id                        = azurerm_log_analytics_workspace.workspace.0.id
  application_type                    = "web"
  internet_ingestion_enabled          = true
  internet_query_enabled              = true
  local_authentication_disabled       = false
  force_customer_storage_for_profiler = false
  sampling_percentage                 = 0
  tags                                = var.required_tags
}
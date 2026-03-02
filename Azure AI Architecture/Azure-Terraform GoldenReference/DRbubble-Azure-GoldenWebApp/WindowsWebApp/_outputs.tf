output "app_id" {
  description = "Web App ID"
  value       = azurerm_windows_web_app.web.id
}

output "app_identity" {
  description = "Web App Identity ID"
  value       = azurerm_windows_web_app.web.identity.0.principal_id
}


output "app_service_name" {
  description = "Name of the created App Service"
  value       = azurerm_windows_web_app.web.name
}

output "app_service_url" {
  description = "Url for the created App Service"
  value       = azurerm_windows_web_app.web.default_hostname
}

output "app_service_plan_id" {
  value       = one(azurerm_service_plan.asp[*].id)
  description = "App service plan Id created within the module"
}

output "application_insights_id" {
  value       = one(azurerm_application_insights.appinsights[*].id)
  description = "Application Insights Id created within the module"
}

output "action_group_id" {
  value       = one(azurerm_monitor_action_group.alert_ag[*].id)
  description = "Action group Id created within the module"
  sensitive   = false
}

output "app_slot_id" {
  description = "Web App slot ID"
  value       = one(azurerm_windows_web_app_slot.slot[*].id)
}

output "app_slot_identity" {
  description = "Web App slot Identity ID"
  value       = one(azurerm_windows_web_app_slot.slot[*].identity.0.principal_id)
}
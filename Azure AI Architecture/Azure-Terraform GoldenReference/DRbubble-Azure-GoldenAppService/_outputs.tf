output "app_id" {
  value = azurerm_app_service.webapp.id
}

output "custom_domain_verification_id" {
  value = azurerm_app_service.webapp.custom_domain_verification_id
}

output "app_identity" {
  value = azurerm_app_service.webapp.identity
}

output "asp_id" {
  value = azurerm_app_service_plan.asp.id
}

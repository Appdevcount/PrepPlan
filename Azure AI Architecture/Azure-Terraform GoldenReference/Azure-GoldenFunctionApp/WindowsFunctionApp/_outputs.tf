output "app_id" {
  value = azurerm_windows_function_app.function.id
}

output "app_identity" {
  value = azurerm_windows_function_app.function.identity.0.principal_id
}
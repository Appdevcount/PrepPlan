resource "azurerm_role_assignment" "function_app_strg_role_assignment" {
  count                = var.storage_uses_managed_identity == true ? 1 : 0
  depends_on           = [azurerm_windows_function_app.function]
  role_definition_name = "Storage Blob Data Contributor"
  scope                = var.storage_account_id
  principal_id         = azurerm_windows_function_app.function.identity.0.principal_id
  principal_type       = "ServicePrincipal"
}
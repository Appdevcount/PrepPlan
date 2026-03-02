resource "azurerm_role_assignment" "function_app_sa_role_assignment" {
  depends_on           = [azurerm_linux_function_app.function]
  role_definition_name = "Storage Blob Data Contributor"
  scope                = var.storage_account_id
  principal_id         = azurerm_linux_function_app.function.identity.0.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "function_app_slot_sa_role_assignment" {
  count                = var.include_function_app_slot ? 1 : 0
  depends_on           = [azurerm_linux_function_app_slot.slot]
  role_definition_name = "Storage Blob Data Contributor"
  scope                = var.storage_account_id
  principal_id         = azurerm_linux_function_app_slot.slot[0].identity.0.principal_id
  principal_type       = "ServicePrincipal"
}
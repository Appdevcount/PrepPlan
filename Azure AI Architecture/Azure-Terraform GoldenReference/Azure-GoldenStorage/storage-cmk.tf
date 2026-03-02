locals {
  cmk_key_name =  var.cmk_keyvault.create_new_keyvault ? "storage-account-cmk-key" : var.cmk_keyvault.cmk_key_name
}

resource "azurerm_role_assignment" "storage_cmk_role_assignment" {
  depends_on           = [azurerm_storage_account.storage_account]
  count                = local.cmk_keyvault_enable_rbac ? 1 : 0
  role_definition_name = "Key Vault Crypto Service Encryption User"
  scope                = local.keyvault_id
  principal_id         = azurerm_storage_account.storage_account.identity.0.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_key_vault_access_policy" "storage_accesspolicy" {
  depends_on   = [azurerm_storage_account.storage_account]
  count        = local.cmk_keyvault_enable_rbac  ? 0 : 1
  key_vault_id = local.keyvault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_storage_account.storage_account.identity.0.principal_id
    
  key_permissions = [ "Get", "UnwrapKey", "WrapKey"]
}

resource "time_sleep" "wait_for_permission_assignment" {
  depends_on      = [azurerm_key_vault_access_policy.storage_accesspolicy, 
                     azurerm_role_assignment.storage_cmk_role_assignment, 
                     azurerm_private_endpoint.endpoint,
                     module.sa_cmk_key_vault]
  create_duration = var.TimerDelay
}
resource "azurerm_storage_account_customer_managed_key" "cmk" {
  depends_on         = [time_sleep.wait_for_permission_assignment]
  storage_account_id = azurerm_storage_account.storage_account.id
  key_vault_id       = local.keyvault_id
  key_name           = local.cmk_key_name
}

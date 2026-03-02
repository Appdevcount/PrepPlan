#Role assignment using RASS (Role as Self Service)
#Note: Only allowed for service principals assigned to subscription
#Reference for RaSS: https://confluence.sys.cigna.com/display/CLOUD/Roles+as+Self+Service
resource "azurerm_role_assignment" "storage_cmk_role_assignment" {
  depends_on           = [module.golden_storage_account_module]
  role_definition_name = "Key Vault Crypto Service Encryption User"
  scope                = data.azurerm_key_vault.vault.id
  principal_id         = module.golden_storage_account_module.storage_account.identity.0.principal_id
  principal_type       = "ServicePrincipal" #Required for RASS
}
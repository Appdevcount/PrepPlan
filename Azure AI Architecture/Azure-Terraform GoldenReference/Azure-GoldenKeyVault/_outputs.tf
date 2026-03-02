output "key_vault_id" {
  value       = azurerm_key_vault.kv.id
  description = "Id of the resultant key vault"
}

output "key_vault_uri" {
  value       = azurerm_key_vault.kv.vault_uri
  description = "URI of the resultant key vault"
}

output "key_vault_rbac_authorization_enabled" {
  value       = azurerm_key_vault.kv.enable_rbac_authorization
  description = "RBAC authorization of the resultant key vault"
}
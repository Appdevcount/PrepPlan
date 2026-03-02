output storage_account_id {
  value       = azurerm_storage_account.storage_account.id
  description = "The id of the storage account created"
  sensitive = false
}

output storage_account_name {
  value       = azurerm_storage_account.storage_account.name
  description = "The name of the storage account created"
  sensitive = false
}

output storage_account {
  value       = azurerm_storage_account.storage_account
  description = "The details of the storage account created"
  sensitive = true
}

output "storage_account_identity" {
  value = azurerm_storage_account.storage_account.identity
  description = "Identity for the storage account created"
  sensitive = false
}




output "cosmos_account_endpoint" {
  value = azurerm_cosmosdb_account.account.endpoint
}
output "cosmos_account_id" {
  value = azurerm_cosmosdb_account.account.id
}
output "cosmos_account_name" {
  value = azurerm_cosmosdb_account.account.name
}

output "connection_strings" {
  value = azurerm_cosmosdb_account.account.connection_strings
  sensitive = true
}

output "primary_key" {
  value = azurerm_cosmosdb_account.account.primary_key
  sensitive = true
}

output "secondary_key" {
  value = azurerm_cosmosdb_account.account.secondary_key
  sensitive = true 
}

output "cosmos_database_name" {
  value = azurerm_cosmosdb_sql_database.database.name
}


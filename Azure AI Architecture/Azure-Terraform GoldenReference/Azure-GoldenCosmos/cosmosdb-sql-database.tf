resource "azurerm_cosmosdb_sql_database" "database" {
  depends_on          = [azurerm_cosmosdb_account.account]
  name                = var.cosmos_database_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.account.name

}
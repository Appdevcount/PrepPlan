# Data source for the Managed Instance on which to deploy
data "azurerm_mssql_managed_instance" "managed_instance" {
  name                  = var.sql_managed_instance_name
  resource_group_name   = var.resource_group_name
}

resource "azurerm_mssql_managed_database" "managed_database" {
  name                  = var.sql_managed_database_name
  managed_instance_id   = data.azurerm_mssql_managed_instance.managed_instance.id  
  short_term_retention_days = var.short_term_retention_days
  long_term_retention_policy {
    immutable_backups_enabled = var.immutable_backups_enabled
    monthly_retention         = var.monthly_retention
    week_of_year              = var.week_of_year
    weekly_retention          = var.weekly_retention
    yearly_retention          = var.yearly_retention
  }
  tags = local.tags 
}
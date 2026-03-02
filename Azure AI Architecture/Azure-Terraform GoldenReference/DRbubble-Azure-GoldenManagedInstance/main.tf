
#Managed Itentity to run SQL MI
data "azurerm_user_assigned_identity" "sqlmi_managed_identity" {
  name                = var.managed_identity
  resource_group_name = var.resource_group_name
}

# Create managed instance
resource "azurerm_mssql_managed_instance" "managed_instance" {
  name                         = "${local.naming_prefix}"
  resource_group_name          = var.resource_group_name
  location                     = var.resource_group_location
  subnet_id                    = data.azurerm_subnet.subnet.id

  azure_active_directory_administrator {
    login_username                      = var.entra_admin_username
    object_id                           = var.entra_admin_object_id
    principal_type                      = var.entra_admin_principal_type
    azuread_authentication_only_enabled = true
  }

  identity{
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.sqlmi_managed_identity.id]
  }
  
  license_type                   = var.license_type
  sku_name                       = var.sku_name
  vcores                         = var.vcores
  storage_size_in_gb             = var.storage_size_in_gb

  collation                      = var.collation
  dns_zone_partner_id            = var.dns_zone_partner_id
  maintenance_configuration_name = local.maintenance_name
# minimum_tls_version            = var.minimum_tls_version
# proxy_override                 = var.proxy_override
# public_data_endpoint_enabled   = var.public_data_endpoint_enabled
  storage_account_type           = var.storage_account_type

  tags                           = local.tags

  timezone_id                    = var.timezone_id
  zone_redundant_enabled         = var.zone_redundant_enabled
  depends_on                     = [azurerm_subnet_route_table_association.subnet_route_table_association]
}

#CIGWORKS Database
resource "azurerm_mssql_managed_database" "managed_database" {
  name                        = local.dba_managed_database_name
  managed_instance_id         = azurerm_mssql_managed_instance.managed_instance.id
  
  short_term_retention_days   = local.short_term_retention_days
  
  long_term_retention_policy {
    immutable_backups_enabled = var.immutable_backups_enabled
    monthly_retention         = var.monthly_retention
    week_of_year              = var.week_of_year
    weekly_retention          = var.weekly_retention
    yearly_retention          = var.yearly_retention
  }

  depends_on                  = [ azurerm_mssql_managed_instance.managed_instance ]

  tags                        = local.tags
}

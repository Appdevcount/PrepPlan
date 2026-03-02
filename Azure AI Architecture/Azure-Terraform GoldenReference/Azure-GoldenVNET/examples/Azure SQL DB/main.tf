###############################################################################
#                                                                             #
# Azure SQL DB Golden Module                                                  #
#                                                                             #
###############################################################################

terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = ">= 3.20.0"
        }
    }

    backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

# Resource Group for SQL Resources to be created
data "azurerm_resource_group" "rsgAzureSql" {
  name     = var.AZ_SQL_RSG
}

data "azurerm_client_config" "current" {
}

###############################################################################
#                                                                             #
# Connect to Key Vault to retrieve secrets                                    #
#                                                                             #
###############################################################################

# Key Vault containing the credentials to use for the SA account
data "azurerm_key_vault" "sqltestkeyvault" {
  name                       = var.AZ_KEYVAULT_NAME
  resource_group_name        = var.AZ_SQL_RSG
}

# Need sql-sa-sample-username and sql-sa-sample-password from the keyvault
data "azurerm_key_vault_secret" "sqlsasampleusername" {
  name                       = var.AZ_SQL_SA_KV_ACCOUNT_NAME
  key_vault_id               = data.azurerm_key_vault.sqltestkeyvault.id
}

data "azurerm_key_vault_secret" "sqlsasamplepassword" {
  name                       = var.AZ_SQL_SA_KV_ACCOUNT_PASSWORD
  key_vault_id               = data.azurerm_key_vault.sqltestkeyvault.id
}

###############################################################################
#                                                                             #
# Set up logging to SIEM                                                      #
#                                                                             #
###############################################################################

# sub_evicore_prod, needed by the logging to SIEM
provider "azurerm" {
  alias                         = "prodsub"
  subscription_id               = var.AZ_PRODUCTION_SUBSCRIPTIONID
  tenant_id                     = var.AZ_TENANTID
  features {}
}

data "azurerm_resource_group" "AZ_SIEM_SECURITY_RSG" {
  provider            = azurerm.prodsub
  name                = var.AZ_SIEM_SECURITY_RSG
}

data "azurerm_log_analytics_workspace" "PD1_CLOUDSIEM_WORKSPACE" {
  provider            = azurerm.prodsub
  name                = var.AZ_SIEM_WORKSPACE_NAME
  resource_group_name = data.azurerm_resource_group.AZ_SIEM_SECURITY_RSG.name
}

###############################################################################
#                                                                             #
# Create Azure SQL Database                                                   #
#                                                                             #
###############################################################################

resource "azurerm_mssql_server" "azuresqldb" {
  name                          = var.AZ_SQL_NAME
  resource_group_name           = data.azurerm_resource_group.rsgAzureSql.name
  location                      = data.azurerm_resource_group.rsgAzureSql.location
  version                       = var.AZ_SQL_VERSION
  administrator_login           = data.azurerm_key_vault_secret.sqlsasampleusername.value
  administrator_login_password  = data.azurerm_key_vault_secret.sqlsasamplepassword.value
  minimum_tls_version           = var.AZ_SQL_TLS_VERSION
  connection_policy             = var.AZ_SQL_CONNECTION_POLICY
  public_network_access_enabled = var.AZ_SQL_PUBLIC_NETWORK_ACCESS

  identity {
    type = "SystemAssigned"
  }

  azuread_administrator {
    azuread_authentication_only = var.AZ_SQL_AZURE_AD_AUTHENTICATION_ONLY
    login_username              = var.AZ_SQL_SA_AAD_LOGIN
    object_id                   = var.AZ_SQL_AZUREAD_ADMIN_OBJECT_ID
  }

  tags                          = var.AZ_SQL_TAGS
}

resource "azurerm_mssql_database" "testdatabase" {
  name                      = "testdatabase"
  server_id                 = azurerm_mssql_server.azuresqldb.id
  collation                 = var.AZ_SQL_COLLATION
  license_type              = var.AZ_SQL_LICENSE
  max_size_gb               = var.AZ_SQL_MAXSIZE
  read_scale                = var.AZ_SQL_READSCALE
  sku_name                  = var.AZ_SQL_SKU
  zone_redundant            = var.AZ_SQL_ZONEREDUNDANT

  long_term_retention_policy {
    weekly_retention        = try(var.AZ_SQL_WEEKLY_RETENTION != null) ? var.AZ_SQL_WEEKLY_RETENTION : null
    monthly_retention       = try(var.AZ_SQL_MONTHLY_RETENTION != null) ? var.AZ_SQL_MONTHLY_RETENTION : null
    yearly_retention        = try(var.AZ_SQL_YEARLY_RETENTION != null) ? var.AZ_SQL_YEARLY_RETENTION : null
    week_of_year            = var.AZ_SQL_WEEKOFYEAR
  }

  tags = var.AZ_SQL_TAGS
}

###############################################################################
#                                                                             #
# Log Analytics                                                               #
#                                                                             #
###############################################################################

resource "azurerm_monitor_diagnostic_setting" "azuresqldbloganalytics" {
  name                       = "${azurerm_mssql_database.testdatabase.name}-DS"
  target_resource_id         = azurerm_mssql_database.testdatabase.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.PD1_CLOUDSIEM_WORKSPACE.id

  log {
    category = "SQLSecurityAuditEvents"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }

  depends_on = [
    azurerm_mssql_server.azuresqldb
  ]

  lifecycle {
    ignore_changes = [log, metric]
  }
}

resource "azurerm_mssql_database_extended_auditing_policy" "azuresqldbloganalyticsauditpolicy" {
  database_id            = "${azurerm_mssql_server.azuresqldb.id}/databases/master"
  log_monitoring_enabled = true

  depends_on = [
    azurerm_mssql_server.azuresqldb,
    azurerm_monitor_diagnostic_setting.azuresqldbloganalytics
  ]
}

resource "azurerm_mssql_server_extended_auditing_policy" "azuresqlserverloganalyticsauditpolicy" {
  server_id              = azurerm_mssql_server.azuresqldb.id
  log_monitoring_enabled = true

  depends_on = [
    azurerm_mssql_server.azuresqldb,
    azurerm_monitor_diagnostic_setting.azuresqldbloganalytics
  ]
}

###############################################################################
#                                                                             #
# Vulnerability Assessment                                                    #
#                                                                             #
###############################################################################

resource "azurerm_storage_account" "sqldbvastorage" {
  name                     = var.AZ_SQL_SA_NAME
  resource_group_name      = data.azurerm_resource_group.rsgAzureSql.name
  location                 = data.azurerm_resource_group.rsgAzureSql.location
  account_tier             = var.AZ_SQL_SA_TIER
  account_replication_type = var.AZ_SQL_SA_REPLICATION
}

resource "azurerm_storage_container" "sqldbvastoragecontainer" {
  name                  = "accteststoragecontainer"
  storage_account_name  = azurerm_storage_account.sqldbvastorage.name
  container_access_type = "container"
}

resource "azurerm_mssql_server_security_alert_policy" "sqldbsecurityalertpol" {
  resource_group_name = data.azurerm_resource_group.rsgAzureSql.name
  server_name         = azurerm_mssql_server.azuresqldb.name
  state               = "Enabled"
}

resource "azurerm_mssql_server_vulnerability_assessment" "sqldbvulnassess" {
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.sqldbsecurityalertpol.id
  storage_container_path          = "${azurerm_storage_account.sqldbvastorage.primary_blob_endpoint}${azurerm_storage_container.sqldbvastoragecontainer.name}/"
  storage_account_access_key      = azurerm_storage_account.sqldbvastorage.primary_access_key

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
    emails                    = var.AZ_SQL_VA_EMAILS
  }
}

###############################################################################
#                                                                             #
# Private Endpoint                                                            #
#                                                                             #
###############################################################################
data "azurerm_virtual_network" "peAzureSqlVnet" {
  name                        = var.AZ_SQL_PE_VNETNAME
  resource_group_name         = data.azurerm_resource_group.rsgAzureSql.name
}

data "azurerm_subnet" "peAzureSqlSubnet" {
  name                        = var.AZ_SQL_PE_SUBNETNAME
  virtual_network_name        = data.azurerm_virtual_network.peAzureSqlVnet.name
  resource_group_name         = data.azurerm_resource_group.rsgAzureSql.name
}

resource "azurerm_private_dns_zone" "peAzureSqlDnsZone1" {
  name                = var.AZ_SQL_PE_PRIVATENAME
  resource_group_name = data.azurerm_resource_group.rsgAzureSql.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "peAzureSqlDnsZoneLink" {
  name = var.AZ_SQL_PE_SUBNETNAME
  resource_group_name = data.azurerm_resource_group.rsgAzureSql.name
  private_dns_zone_name = azurerm_private_dns_zone.peAzureSqlDnsZone1.name
  virtual_network_id = data.azurerm_virtual_network.peAzureSqlVnet.id
}

resource "azurerm_private_dns_zone" "peAzureSqlDnsZone2" {
  name                = "${azurerm_mssql_database.testdatabase.name}.database.windows.net"
  resource_group_name = data.azurerm_resource_group.rsgAzureSql.name
}

resource "azurerm_private_endpoint" "peAzureSql" {
  depends_on = [
    azurerm_mssql_server.azuresqldb
  ]

  name = var.AZ_SQL_PE_PRIVATEENDPOINTNAME
  location = data.azurerm_resource_group.rsgAzureSql.location
  resource_group_name = data.azurerm_resource_group.rsgAzureSql.name
  subnet_id = data.azurerm_subnet.peAzureSqlSubnet.id
  private_service_connection {
    name = var.AZ_SQL_PE_PRIVATEENDPOINTNAME
    is_manual_connection = "false"
    private_connection_resource_id = azurerm_mssql_server.azuresqldb.id
    subresource_names = ["sqlServer"]
  }
}

data "azurerm_private_endpoint_connection" "peAzureSqlConnection" {
  depends_on = [
    azurerm_private_endpoint.peAzureSql
  ]
  name = azurerm_private_endpoint.peAzureSql.name
  resource_group_name = data.azurerm_resource_group.rsgAzureSql.name
}

resource "azurerm_private_dns_a_record" "peAzureSqlDnsARecord" {
  depends_on = [
    azurerm_mssql_server.azuresqldb
  ]
  name = lower(azurerm_mssql_server.azuresqldb.name)
  zone_name = azurerm_private_dns_zone.peAzureSqlDnsZone2.name
  resource_group_name = data.azurerm_resource_group.rsgAzureSql.name
  ttl = 300
  records = [data.azurerm_private_endpoint_connection.peAzureSqlConnection.private_service_connection.0.private_ip_address]
}

# Create a Private DNS to VNET link
resource "azurerm_private_dns_zone_virtual_network_link" "peAzureSqlDnsZoneToVnetLink" {
  name = "${lower(azurerm_mssql_server.azuresqldb.name)}zonetovnet"
  resource_group_name = data.azurerm_resource_group.rsgAzureSql.name
  private_dns_zone_name = azurerm_private_dns_zone.peAzureSqlDnsZone2.name
  virtual_network_id = data.azurerm_virtual_network.peAzureSqlVnet.id
}

###############################################################################
#                                                                             #
# Encryption with customer-managed keys                                       #
#                                                                             #
###############################################################################
# Set access policies for keys
resource "azurerm_key_vault_access_policy" "database" {
  key_vault_id = data.azurerm_key_vault.sqltestkeyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_mssql_server.azuresqldb.identity.0.principal_id

  key_permissions    = ["Get", "Create", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]

  depends_on = [
    azurerm_mssql_server.azuresqldb
  ]
}

resource "azurerm_key_vault_access_policy" "client" {
  key_vault_id = data.azurerm_key_vault.sqltestkeyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]

  depends_on = []
}

resource "azurerm_key_vault_key" "AZ_SQL_TDEKEY" {
  name         = "${azurerm_mssql_server.azuresqldb.name}key"
  key_vault_id = data.azurerm_key_vault.sqltestkeyvault.id
  key_type     = var.AZ_SQL_KV_KEYTYPE
  key_size     = var.AZ_SQL_KV_KEYSIZE
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    azurerm_key_vault_access_policy.client,
    azurerm_mssql_server.azuresqldb
  ]
}

# Set up Transparent Data Encryption
resource "azurerm_mssql_server_transparent_data_encryption" "azuremssqltds" {
  depends_on = [
    data.azurerm_resource_group.rsgAzureSql,
    azurerm_mssql_server.azuresqldb,
    azurerm_key_vault_key.AZ_SQL_TDEKEY
  ]
  server_id     = azurerm_mssql_server.azuresqldb.id
  key_vault_key_id  = azurerm_key_vault_key.AZ_SQL_TDEKEY.id
}
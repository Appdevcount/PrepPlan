###############################################################################
#                                                                             #
# Azure SQL Managed Instance Golden Module                                    #
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

# Default provider
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

data "azurerm_resource_group" "AZ_SQL_server" {
  name     = var.AZ_SQL_RSG
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

# Get sql-sa-sample-username and sql-sa-sample-password from the keyvault
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
# Set up subnet with network security rules                                   #
#                                                                             #
###############################################################################
resource "azurerm_network_security_group" "AZ_SQL_NSG" {
  name                        = var.AZ_SQL_NSG
  location                    = data.azurerm_resource_group.AZ_SQL_server.location
  resource_group_name         = var.AZ_SQL_RSG

  tags                          = var.AZ_SQL_TAGS

  lifecycle {
    ignore_changes = [ tags ]
  }

  depends_on = [

  ]
}

resource "azurerm_network_security_rule" "allow_management_inbound" {
  name                        = "allow_management_inbound"
  priority                    = 106
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["9000", "9003", "1438", "1440", "1452"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.AZ_SQL_RSG
  network_security_group_name = azurerm_network_security_group.AZ_SQL_NSG.name

  depends_on = [
    azurerm_network_security_group.AZ_SQL_NSG
  ]
}

resource "azurerm_network_security_rule" "allow_misubnet_inbound" {
  name                        = "allow_misubnet_inbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = var.AZ_SQL_RSG
  network_security_group_name = azurerm_network_security_group.AZ_SQL_NSG.name

  depends_on = [
    azurerm_network_security_group.AZ_SQL_NSG
  ]
}

resource "azurerm_network_security_rule" "allow_health_probe_inbound" {
  name                        = "allow_health_probe_inbound"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.AZ_SQL_RSG
  network_security_group_name = azurerm_network_security_group.AZ_SQL_NSG.name

  depends_on = [
    azurerm_network_security_group.AZ_SQL_NSG
  ]
}

resource "azurerm_network_security_rule" "allow_tds_inbound" {
  name                        = "allow_tds_inbound"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = var.AZ_SQL_RSG
  network_security_group_name = azurerm_network_security_group.AZ_SQL_NSG.name

  depends_on = [
    azurerm_network_security_group.AZ_SQL_NSG
  ]
}

resource "azurerm_network_security_rule" "deny_all_inbound" {
  name                        = "deny_all_inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.AZ_SQL_RSG
  network_security_group_name = azurerm_network_security_group.AZ_SQL_NSG.name

  depends_on = [
    azurerm_network_security_group.AZ_SQL_NSG
  ]
}

resource "azurerm_network_security_rule" "allow_management_outbound" {
  name                        = "allow_management_outbound"
  priority                    = 102
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443", "12000"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.AZ_SQL_RSG
  network_security_group_name = azurerm_network_security_group.AZ_SQL_NSG.name

  depends_on = [
    azurerm_network_security_group.AZ_SQL_NSG
  ]
}

resource "azurerm_network_security_rule" "allow_misubnet_outbound" {
  name                        = "allow_misubnet_outbound"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = var.AZ_SQL_RSG
  network_security_group_name = azurerm_network_security_group.AZ_SQL_NSG.name

  depends_on = [
    azurerm_network_security_group.AZ_SQL_NSG
  ]
}

resource "azurerm_network_security_rule" "deny_all_outbound" {
  name                        = "deny_all_outbound"
  priority                    = 4096
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.AZ_SQL_RSG
  network_security_group_name = azurerm_network_security_group.AZ_SQL_NSG.name

  depends_on = [
    azurerm_network_security_group.AZ_SQL_NSG
  ]
}

###############################################################################
#                                                                             #
# Configure MI subnet                                                         #
#                                                                             #
###############################################################################
data "azurerm_virtual_network" "azuresqlminetwork" {
  name                = var.AZ_SQL_VNET
  resource_group_name = var.AZ_SQL_RSG
}

data "azurerm_subnet" "azuresqlmisubnet" {
  name                 = var.AZ_SQL_SUBNET
  resource_group_name = var.AZ_SQL_RSG
  virtual_network_name = data.azurerm_virtual_network.azuresqlminetwork.name
}

resource "azurerm_subnet_network_security_group_association" "azuresqlminsgassn" {
  subnet_id                   = data.azurerm_subnet.azuresqlmisubnet.id
  network_security_group_id   = azurerm_network_security_group.AZ_SQL_NSG.id
}

resource "azurerm_route_table" "azuresqlmiroutetabl" {
  name                          = "routetable-mi"
  location                      = data.azurerm_resource_group.AZ_SQL_server.location
  resource_group_name           = var.AZ_SQL_RSG
  disable_bgp_route_propagation = false

  tags                          = var.AZ_SQL_TAGS

  lifecycle {
    ignore_changes = [ tags ]
  }

  depends_on = []
}

resource "azurerm_subnet_route_table_association" "azuresqlmiroutetablassn" {
  subnet_id      = data.azurerm_subnet.azuresqlmisubnet.id
  route_table_id = azurerm_route_table.azuresqlmiroutetabl.id
}

###############################################################################
#                                                                             #
# Create SQL MI Instance                                                      #
#                                                                             #
###############################################################################
resource "azurerm_mssql_managed_instance" "azuresqlmi" {
  name                          = var.AZ_SQL_NAME
  resource_group_name           = var.AZ_SQL_RSG
  location                      = data.azurerm_resource_group.AZ_SQL_server.location

  license_type                  = var.AZ_SQL_LICENSE_TYPE
  sku_name                      = var.AZ_SQL_SKU_NAME
  storage_size_in_gb            = var.AZ_SQL_STORAGE_SIZE
  subnet_id                     = data.azurerm_subnet.azuresqlmisubnet.id
  vcores                        = var.AZ_SQL_VCORES
  minimum_tls_version           = var.AZ_SQL_TLS_VERSION

  identity {
    type                        = "SystemAssigned"
  }

  administrator_login           = data.azurerm_key_vault_secret.sqlsasampleusername.value
  administrator_login_password  = data.azurerm_key_vault_secret.sqlsasamplepassword.value

  tags                          = var.AZ_SQL_TAGS

  lifecycle {
    ignore_changes = [ tags ]
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.azuresqlminsgassn,
    azurerm_subnet_route_table_association.azuresqlmiroutetablassn
  ]
}

###############################################################################
#                                                                             #
# Set up vulnerability assessment                                             #
#                                                                             #
###############################################################################
resource "azurerm_security_center_subscription_pricing" "mdc_sqlservers" {
  tier          = var.AZ_SQL_VA_TIER
  resource_type = "SqlServers"
}

# Storage Container for Vulnerabilities identified
resource "azurerm_storage_account" "sqldbvastorage" {
  name                     = lower(replace("${var.AZ_SQL_NAME}va", "-", ""))   # string can only be lowercase letters and numbers
  resource_group_name      = var.AZ_SQL_RSG
  location                 = data.azurerm_resource_group.AZ_SQL_server.location
  account_tier             = var.AZ_SQL_SA_TIER
  account_replication_type = var.AZ_SQL_SA_REPLICATION
  allow_nested_items_to_be_public = var.AZ_SQL_SA_PUBLICACCESS
  cross_tenant_replication_enabled = var.AZ_SQL_SA_CROSSTENANTREPL

  identity {
    type = "SystemAssigned"
  }

  tags                          = var.AZ_SQL_TAGS

  lifecycle {
    ignore_changes = [ tags ]
  }
}

# Setup a storage account encryption key
# Set access policies for keys
resource "azurerm_key_vault_access_policy" "storage" {
  key_vault_id = data.azurerm_key_vault.sqltestkeyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_storage_account.sqldbvastorage.identity.0.principal_id

  key_permissions    = ["Get", "Create", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]

  depends_on = [
    azurerm_storage_account.sqldbvastorage
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

resource "azurerm_key_vault_key" "AZ_SQL_VASTORAGEKEY" {
  name         = "${var.AZ_SQL_SA_NAME}key"
  key_vault_id = data.azurerm_key_vault.sqltestkeyvault.id
  key_type     = var.AZ_SQL_KV_KEYTYPE
  key_size     = var.AZ_SQL_KV_KEYSIZE
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    azurerm_key_vault_access_policy.client,
    azurerm_storage_account.sqldbvastorage
  ]
}

# Apply storage account encryption key
resource "azurerm_storage_account_customer_managed_key" "AS_SQL_BACKUPSTORAGE" {
  storage_account_id  = azurerm_storage_account.sqldbvastorage.id
  key_vault_id        = data.azurerm_key_vault.sqltestkeyvault.id
  key_name            = azurerm_key_vault_key.AZ_SQL_VASTORAGEKEY.name

  depends_on = [
    azurerm_key_vault_access_policy.client,
    azurerm_storage_account.sqldbvastorage,
    azurerm_key_vault_key.AZ_SQL_VASTORAGEKEY
  ]
}

resource "azurerm_storage_container" "sqldbvastoragecontainer" {
  name                  = "accteststoragecontainer"
  storage_account_name  = azurerm_storage_account.sqldbvastorage.name
  container_access_type = "private"
}

resource "azurerm_mssql_managed_instance_vulnerability_assessment" "azuresqlmiva" {
  managed_instance_id             = azurerm_mssql_managed_instance.azuresqlmi.id
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
# Set up TDE with customer-managed key                                        #
#                                                                             #
###############################################################################
# Set access policies for keys
resource "azurerm_key_vault_access_policy" "sqldataencrypt" {
  key_vault_id = data.azurerm_key_vault.sqltestkeyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_mssql_managed_instance.azuresqlmi.identity.0.principal_id

  key_permissions    = ["Get", "Create", "Update", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]

  depends_on = [
    azurerm_mssql_managed_instance.azuresqlmi
  ]
}

resource "azurerm_key_vault_key" "AZ_SQL_SQLENCRYPTKEY" {
  name         = "${var.AZ_SQL_NAME}-sqlkey"
  key_vault_id = data.azurerm_key_vault.sqltestkeyvault.id
  key_type     = var.AZ_SQL_KV_KEYTYPE
  key_size     = var.AZ_SQL_KV_KEYSIZE
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  tags                          = var.AZ_SQL_TAGS

  depends_on = [
    azurerm_key_vault_access_policy.sqldataencrypt
  ]
}

# currently, there is no way to set up Transparent Data Encryption this natively in Terraform. Do it via AZ CLI:
# az sql mi tde-key set --server-key-type AzureKeyVault --kid $keyId --managed-instance $instance --resource-group $resourceGroup
resource "null_resource" "azuresqlmitde" {
  provisioner "local-exec" {
    command = "az sql mi tde-key set --server-key-type AzureKeyVault --kid ${azurerm_key_vault_key.AZ_SQL_SQLENCRYPTKEY.id} --managed-instance ${azurerm_mssql_managed_instance.azuresqlmi.name} --resource-group ${var.AZ_SQL_RSG}"
  }

  depends_on = [
    azurerm_key_vault_key.AZ_SQL_SQLENCRYPTKEY
  ]
}

###############################################################################
#                                                                             #
# Azure Active Directory administrator setup                                  #
#                                                                             #
###############################################################################
resource "azuread_application" "azuresqlmi" {
  display_name                      = "SP_${var.AZ_SQL_NAME}"
  sign_in_audience                  = "AzureADMyOrg"
}

resource "azuread_service_principal" "azuresqlmisp" {
  application_id              = azuread_application.azuresqlmi.application_id

  depends_on = [
    azuread_application.azuresqlmi
  ]
}

resource "azuread_directory_role" "directoryreader" {
  display_name                = "Directory readers"
}

resource "azuread_directory_role_assignment" "azuresqlmi" {
  role_id                     = azuread_directory_role.directoryreader.template_id
  principal_object_id         = azurerm_mssql_managed_instance.azuresqlmi.identity.0.principal_id

  depends_on = [
    azuread_directory_role.directoryreader,
    azuread_application.azuresqlmi,
    azuread_service_principal.azuresqlmisp,
    azurerm_mssql_managed_instance.azuresqlmi
  ]
}

resource "azurerm_mssql_managed_instance_active_directory_administrator" "mssqlaadadmin" {
  managed_instance_id         = azurerm_mssql_managed_instance.azuresqlmi.id
  login_username              = azuread_service_principal.azuresqlmisp.display_name
  object_id                   = azurerm_mssql_managed_instance.azuresqlmi.identity.0.principal_id
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  azuread_authentication_only = true

  depends_on = [
    azuread_directory_role.directoryreader,
    azuread_application.azuresqlmi,
    azuread_service_principal.azuresqlmisp,
    azurerm_mssql_managed_instance.azuresqlmi,
    azuread_directory_role_assignment.azuresqlmi
  ]
}

###############################################################################
#                                                                             #
# Vulnerability Assessment                                                    #
#                                                                             #
###############################################################################
resource "azurerm_mssql_managed_instance_vulnerability_assessment" "sqlmivulnassess" {
  managed_instance_id             = azurerm_mssql_managed_instance.azuresqlmi.id
  storage_container_path          = "${azurerm_storage_account.sqldbvastorage.primary_blob_endpoint}${azurerm_storage_container.sqldbvastoragecontainer.name}/"
  storage_account_access_key      = azurerm_storage_account.sqldbvastorage.primary_access_key

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
    emails = [
      "brian.pickering@evicore.com"
    ]
  }

  depends_on = [
    azurerm_mssql_managed_instance.azuresqlmi,
    azurerm_storage_account.sqldbvastorage
  ]
}

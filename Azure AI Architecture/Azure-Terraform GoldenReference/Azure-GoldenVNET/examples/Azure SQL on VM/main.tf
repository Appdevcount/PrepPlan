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

# Resource Group where SQL Resources will be created
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
  name                       = "sqlsasampleusername"
  key_vault_id               = data.azurerm_key_vault.sqltestkeyvault.id
}

data "azurerm_key_vault_secret" "sqlsasamplepassword" {
  name                       = "sqlsasamplepassword"
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
data "azurerm_virtual_network" "azuresqlvmnetwork" {
  name                = var.AZ_SQL_VNET
  resource_group_name = data.azurerm_resource_group.AZ_SQL_server.name
}

data "azurerm_subnet" "azuresqlvmsubnet" {
  name                 = var.AZ_SQL_SUBNET
  resource_group_name = data.azurerm_resource_group.AZ_SQL_server.name
  virtual_network_name = data.azurerm_virtual_network.azuresqlvmnetwork.name
}

# Configure route table for subnets
resource "azurerm_route_table" "azuresqlroutetabl" {
  name                          = "routetable-vm"
  location                      = data.azurerm_resource_group.AZ_SQL_server.location
  resource_group_name           = data.azurerm_resource_group.AZ_SQL_server.name
  disable_bgp_route_propagation = false

  tags                          = var.AZ_SQL_TAGS

  lifecycle {
    ignore_changes = [ tags ]
  }

  depends_on = []
}

resource "azurerm_subnet_route_table_association" "azuresqlroutetablassn" {
  subnet_id      = data.azurerm_subnet.azuresqlvmsubnet.id
  route_table_id = azurerm_route_table.azuresqlroutetabl.id
}

# Configure network security group for SQL subnet
resource "azurerm_network_security_group" "AZ_SQL_NSG" {
  name                        = "${var.AZ_SQL_SUBNET}-sql"
  location                    = data.azurerm_resource_group.AZ_SQL_server.location
  resource_group_name         = data.azurerm_resource_group.AZ_SQL_server.name

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
  resource_group_name         = data.azurerm_resource_group.AZ_SQL_server.name
  network_security_group_name = azurerm_network_security_group.AZ_SQL_NSG.name

  depends_on = [
    azurerm_network_security_group.AZ_SQL_NSG
  ]
}

resource "azurerm_network_security_rule" "allow_sqlsubnet_inbound" {
  name                        = "allow_sqlsubnet_inbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.AZ_SQL_server.name
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
  resource_group_name         = data.azurerm_resource_group.AZ_SQL_server.name
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
  resource_group_name         = data.azurerm_resource_group.AZ_SQL_server.name
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
  resource_group_name         = data.azurerm_resource_group.AZ_SQL_server.name
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
  resource_group_name         = data.azurerm_resource_group.AZ_SQL_server.name
  network_security_group_name = azurerm_network_security_group.AZ_SQL_NSG.name

  depends_on = [
    azurerm_network_security_group.AZ_SQL_NSG
  ]
}

resource "azurerm_network_security_rule" "allow_sqlsubnet_outbound" {
  name                        = "allow_sqlsubnet_outbound"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.AZ_SQL_server.name
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
  resource_group_name         = data.azurerm_resource_group.AZ_SQL_server.name
  network_security_group_name = azurerm_network_security_group.AZ_SQL_NSG.name

  depends_on = [
    azurerm_network_security_group.AZ_SQL_NSG
  ]
}

resource "azurerm_network_security_rule" "allow_rdp_inbound" {
  name                        = "allow_rdp_inbound"
  priority                    = 107
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["3389"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.AZ_SQL_server.name
  network_security_group_name = azurerm_network_security_group.AZ_SQL_NSG.name

  depends_on = [
    azurerm_network_security_group.AZ_SQL_NSG
  ]
}

resource "azurerm_network_security_rule" "allow_winadminctr_inbound" {
  name                        = "allow_winadmin_inbound"
  priority                    = 108
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["6516"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.AZ_SQL_server.name
  network_security_group_name = azurerm_network_security_group.AZ_SQL_NSG.name

  depends_on = [
    azurerm_network_security_group.AZ_SQL_NSG
  ]
}

resource "azurerm_subnet_network_security_group_association" "azuresqlnsgassn" {
  subnet_id                   = data.azurerm_subnet.azuresqlvmsubnet.id
  network_security_group_id   = azurerm_network_security_group.AZ_SQL_NSG.id
}

###############################################################################
#                                                                             #
# Create VM network interface and VM                                          #
#                                                                             #
###############################################################################
resource "azurerm_public_ip" "AZ_SQL_VM" {
  name                = "${var.AZ_SQL_VMNAME}-pubip"
  resource_group_name = data.azurerm_resource_group.AZ_SQL_server.name
  location            = data.azurerm_resource_group.AZ_SQL_server.location
  allocation_method   = "Static"

  tags = var.AZ_SQL_TAGS
}

resource "azurerm_network_interface" "AZ_SQL_VM" {
  name                = "${var.AZ_SQL_VMNAME}-nic"
  resource_group_name = data.azurerm_resource_group.AZ_SQL_server.name
  location            = data.azurerm_resource_group.AZ_SQL_server.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.azuresqlvmsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.AZ_SQL_VM.id
  }

}

resource "azurerm_windows_virtual_machine" "AZ_SQL_VM" {
  name                = var.AZ_SQL_VMNAME
  resource_group_name = data.azurerm_resource_group.AZ_SQL_server.name
  location            = data.azurerm_resource_group.AZ_SQL_server.location
  size                = var.AZ_SQL_VMSIZE
  admin_username      = data.azurerm_key_vault_secret.sqlsasampleusername.value
  admin_password      = data.azurerm_key_vault_secret.sqlsasamplepassword.value
  network_interface_ids = [
    azurerm_network_interface.AZ_SQL_VM.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.AZ_SQL_VMSTORAGETYPE
  }

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2017-ws2019"
    sku       = "sqldev"
    version   = "latest"
  }
}

# add a data disk
resource "azurerm_managed_disk" "datadisk" {
  name                    = "${azurerm_windows_virtual_machine.AZ_SQL_VM.name}-data-disk01" 
  location                = data.azurerm_resource_group.AZ_SQL_server.location
  resource_group_name     = data.azurerm_resource_group.AZ_SQL_server.name
  storage_account_type    = "Standard_LRS"
  create_option           = "Empty"
  disk_size_gb            = 1000
  tags                    = var.AZ_SQL_TAGS
}

resource "azurerm_virtual_machine_data_disk_attachment" "datadisk_attach" {
  managed_disk_id    = azurerm_managed_disk.datadisk.id
  virtual_machine_id = azurerm_windows_virtual_machine.AZ_SQL_VM.id
  lun                = 1
  caching            = "ReadWrite"
}

# add a log disk
resource "azurerm_managed_disk" "logdisk" {
  name                    = "${azurerm_windows_virtual_machine.AZ_SQL_VM.name}-log-disk01" 
  location                = data.azurerm_resource_group.AZ_SQL_server.location
  resource_group_name     = data.azurerm_resource_group.AZ_SQL_server.name
  storage_account_type    = "Standard_LRS"
  create_option           = "Empty"
  disk_size_gb            = 500
  tags                    = var.AZ_SQL_TAGS
}

resource "azurerm_virtual_machine_data_disk_attachment" "logdisk_attach" {
  managed_disk_id         = azurerm_managed_disk.logdisk.id
  virtual_machine_id      = azurerm_windows_virtual_machine.AZ_SQL_VM.id
  lun                     = 2
  caching                 = "ReadWrite"
}

###############################################################################
#                                                                             #
# Create Storage Account for SQL Backups                                      #
#                                                                             #
###############################################################################
resource "azurerm_storage_account" "SQLDBBACKUPSTORAGE" {
  name                     = var.AZ_SQL_SA_BACKUP_NAME
  resource_group_name      = data.azurerm_resource_group.AZ_SQL_server.name
  location                 = data.azurerm_resource_group.AZ_SQL_server.location
  account_tier             = var.AZ_SQL_SA_TIER
  account_replication_type = var.AZ_SQL_SA_REPLICATION
  allow_nested_items_to_be_public = var.AZ_SQL_SA_PUBLICACCESS
  cross_tenant_replication_enabled = var.AZ_SQL_SA_CROSSTENANTREPL

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [ tags ]
  }
}

data "azuread_service_principal" "SQLDBBACKUPSTORAGESP" {
  object_id            = var.AZ_SQL_SP
}

# Setup a storage account encryption key
# Set access policies for keys
resource "azurerm_key_vault_access_policy" "storage" {
  key_vault_id = data.azurerm_key_vault.sqltestkeyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_storage_account.SQLDBBACKUPSTORAGE.identity.0.principal_id

  key_permissions    = ["Get", "Create", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]

  depends_on = [
    azurerm_storage_account.SQLDBBACKUPSTORAGE
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
  name         = "${var.AZ_SQL_SA_BACKUP_NAME}key"
  key_vault_id = data.azurerm_key_vault.sqltestkeyvault.id
  key_type     = var.AZ_SQL_KV_KEYTYPE
  key_size     = var.AZ_SQL_KV_KEYSIZE
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    azurerm_key_vault_access_policy.client,
    azurerm_storage_account.SQLDBBACKUPSTORAGE
  ]
}

# Apply storage account encryption key
resource "azurerm_storage_account_customer_managed_key" "AS_SQL_BACKUPSTORAGE" {
  storage_account_id  = azurerm_storage_account.SQLDBBACKUPSTORAGE.id
  key_vault_id        = data.azurerm_key_vault.sqltestkeyvault.id
  key_name            = azurerm_key_vault_key.AZ_SQL_VASTORAGEKEY.name

  depends_on = [
    azurerm_key_vault_access_policy.client,
    azurerm_storage_account.SQLDBBACKUPSTORAGE,
    azurerm_key_vault_key.AZ_SQL_VASTORAGEKEY,
    azurerm_windows_virtual_machine.AZ_SQL_VM
  ]
}

###############################################################################
#                                                                             #
# Create SQL Server on VM, with automatic backups to Storage Account          #
#                                                                             #
###############################################################################
resource "azurerm_mssql_virtual_machine" "AZ_SQL_VM" {
  virtual_machine_id               = azurerm_windows_virtual_machine.AZ_SQL_VM.id
  sql_license_type                 = var.AZ_SQL_LICENSE
  r_services_enabled               = false            # R Services = Machine Learning Services in SQL Server 2017+
  sql_connectivity_port            = var.AZ_SQL_PORT
  sql_connectivity_type            = var.AZ_SQL_CONNECTIVITYTYPE
  sql_connectivity_update_password = data.azurerm_key_vault_secret.sqlsasamplepassword.value
  sql_connectivity_update_username = data.azurerm_key_vault_secret.sqlsasampleusername.value

  storage_configuration {
    disk_type                       = "NEW"
    storage_workload_type           = "GENERAL"

    # The storage_settings block supports the following:
    data_settings {
      default_file_path = "F:\\Data"     # (Required) The SQL Server default path
      luns = [azurerm_virtual_machine_data_disk_attachment.datadisk_attach.lun]
    }

    log_settings {
      default_file_path = "G:\\Log"     # (Required) The SQL Server default path
      luns = [azurerm_virtual_machine_data_disk_attachment.logdisk_attach.lun]                                 # (Required) A list of Logical Unit Numbers for the disks.
    }
  }

  auto_backup {
    encryption_enabled              = var.AZ_SQL_BACKUPENCRYPTENABLED
    encryption_password             = data.azurerm_key_vault_secret.sqlsasamplepassword.value # for actual deployments, this should be a different secret
    storage_blob_endpoint           = azurerm_storage_account.SQLDBBACKUPSTORAGE.primary_blob_endpoint
    storage_account_access_key      = azurerm_storage_account.SQLDBBACKUPSTORAGE.primary_access_key
    system_databases_backup_enabled = var.AZ_SQL_BACKUPSYSTEMDATABASES
    retention_period_in_days        = var.AZ_SQL_BACKUPRETENTION
  }

  auto_patching {
    day_of_week                            = var.AZ_SQL_PATCHDAY
    maintenance_window_duration_in_minutes = var.AZ_SQL_MAINTWINDOWDURATION
    maintenance_window_starting_hour       = var.AZ_SQL_MAINTWINDOWSTARTHOUR
  }

  tags                          = var.AZ_SQL_TAGS

  timeouts {
    create                      = "60m"
    update                      = "60m"
    read                        = "10m"
    delete                      = "60m"
  }

  depends_on = [
    azurerm_key_vault_access_policy.client,
    azurerm_storage_account.SQLDBBACKUPSTORAGE,
    azurerm_key_vault_key.AZ_SQL_VASTORAGEKEY,
    azurerm_windows_virtual_machine.AZ_SQL_VM,
    azurerm_virtual_machine_data_disk_attachment.datadisk_attach,
    azurerm_virtual_machine_data_disk_attachment.logdisk_attach
  ]
}
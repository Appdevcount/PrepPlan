#Create NIC
data "azurerm_subnet" "nicsubnet" {
  count = length(var.nics)
  #  name                 = var.subnet_name
  #  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.nic_resource_group_name == "vmrg" ? var.resource_group_name : var.nic_resource_group_name
  name                 = var.nics[count.index].subnet_name
  virtual_network_name = var.nics[count.index].virtual_network_name
}

resource "azurerm_network_interface" "vmnic" {
  count                         = length(var.nics)
  name                          = "${var.name}-${format("nic%02.0f", count.index + 1)}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
#  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "${var.name}-${format("ip%02.0f", count.index + 1)}"
    subnet_id                     = data.azurerm_subnet.nicsubnet[count.index].id
    private_ip_address_allocation = var.private_ip_address_allocation
  }

  tags = local.tags
}

locals {
  vm_nics = chunklist(azurerm_network_interface.vmnic[*].id, length(var.nics))
}

#Get source image from Shared Image Gallery
data "azurerm_shared_image" "source_image" {
  provider            = azurerm.sig
  resource_group_name = local.gallery_resource_group_name
  gallery_name        = var.os_type == "Linux" ? local.linux_gallery : local.windows_gallery
  name                = var.image_name
}

#Create Linux VM if os_type is Linux
resource "azurerm_linux_virtual_machine" "linux-vm" {
  count = var.os_type == "Linux" ? 1 : 0

  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.size
  dedicated_host_id               = var.dedicated_host_id
  zone                            = var.zone
  admin_username                  = var.admin_username
  allow_extension_operations      = "true"
  disable_password_authentication = "true"
  network_interface_ids           = element(local.vm_nics, count.index)

  custom_data                = var.custom_data
  encryption_at_host_enabled = var.encryption_at_host_enabled
  priority                   = var.priority

  tags = local.data_tags

  identity {
    type = "SystemAssigned"
  }

  source_image_id = var.image_version_id == "latest" ? data.azurerm_shared_image.source_image.id : var.image_version_id

  plan {
    publisher = local.plan_publisher
    product   = local.plan_offer
    name      = local.plan_sku
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_password
  }

  os_disk {
    name                 = "${var.name}-OSdisk"
    caching              = var.OS_caching
    storage_account_type = var.OS_storage_account_type
    #NOTE: The Disk Encryption Set must have the Reader Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault
    disk_encryption_set_id = var.disk_encryption_set_id

    # V2 - For ephemeral OS disk
    #    diff_disk_settings {
    #        Optional                    = "local"
    #    }
  }

  additional_capabilities {
    ultra_ssd_enabled = var.ultra_ssd_enabled
  }

  # Enable boot diagnostics if URI provided
  boot_diagnostics {
    storage_account_uri = var.storage_account_uri
  }
}

#Create Windows VM if os_type is Windows
resource "azurerm_windows_virtual_machine" "windows-vm" {
  count = var.os_type == "Windows" ? 1 : 0

  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  size                       = var.size
  dedicated_host_id          = var.dedicated_host_id
  zone                       = var.zone
  admin_username             = var.admin_username
  admin_password             = var.admin_password
  allow_extension_operations = "true"
  network_interface_ids      = element(local.vm_nics, count.index)
  custom_data                = var.custom_data
  encryption_at_host_enabled = var.encryption_at_host_enabled
  priority                   = var.priority
  enable_automatic_updates   = var.enable_automatic_updates
  patch_mode                 = var.enable_automatic_updates == false ? "Manual" : "AutomaticByOS"
  secure_boot_enabled        = true
  vtpm_enabled               = true

  tags = local.data_tags

  identity {
    type = "SystemAssigned"
  }

  source_image_id = var.image_version_id == "latest" ? data.azurerm_shared_image.source_image.id : var.image_version_id

  /*
  plan {
    publisher = var.publisher
    name      = var.sku
    product   = var.offer
  }
*/

  os_disk {
    name                 = "${var.name}-OSdisk"
    caching              = "ReadWrite"
    storage_account_type = var.OS_storage_account_type
    #NOTE: The Disk Encryption Set must have the Reader Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault
    disk_encryption_set_id = var.disk_encryption_set_id
  }

  # Enable boot diagnostice if URI supplied
  boot_diagnostics {
    storage_account_uri = var.storage_account_uri
  }
}

#Create data disks
locals {
  data_disk_map = { for data_disk in var.data_disks : data_disk.name => data_disk }
}

resource "azurerm_managed_disk" "vmDataDisk" {
  for_each               = local.data_disk_map
  name                   = "${var.name}-DataDisk${each.key}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  storage_account_type   = each.value.storage_account_type
  create_option          = "Empty"
  disk_size_gb           = each.value.disk_size_gb
  disk_encryption_set_id = var.disk_encryption_set_id
  tags                   = local.data_tags
}

#NEED TO PULL VMID INTO A LOCAL VARIABLE ***AFTER*** IT IS CREATED---don't think that will work (alternate us count again)
resource "azurerm_virtual_machine_data_disk_attachment" "vmDataDisk" {
  for_each           = local.data_disk_map
  managed_disk_id    = azurerm_managed_disk.vmDataDisk[each.key].id
  virtual_machine_id = var.os_type == "Linux" ? azurerm_linux_virtual_machine.linux-vm[0].id : azurerm_windows_virtual_machine.windows-vm[0].id
  lun                = each.value.lun
  caching            = each.value.caching
}

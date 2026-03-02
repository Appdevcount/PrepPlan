###########################################################
## Testing for Azure-GoldenNewModule typical environment ##
###########################################################

terraform {
  required_version = ">= 1.2"
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">= 2.0"
      configuration_aliases = [azurerm.sig]
    }
  }
}

provider "azurerm" {
  subscription_id = local.cloudcoe-dev
  features {}
}

provider "azurerm" {
  #Subscription holding Shared Image Gallery
  alias           = "sig"
  subscription_id = local.IT-Production_sig
  features {}
}

###########################################
# Build simple environment to deploy into #
###########################################

resource "azurerm_resource_group" "vms" {
  name     = var.resource_group_name
  location = var.location

  tags = var.required_tags
}

resource "azurerm_resource_group" "nics" {
  count = var.nic_resource_group_name == "vmrg" ? 0 : 1

  name     = var.nic_resource_group_name
  location = var.location

  tags = var.required_tags
}

#switch this over to vNet Golden Module when version compatibility issues resolved
## If using this code as an example, note that only 1 nic subnet is recognized as coded here
resource "azurerm_virtual_network" "vnet" {
  depends_on = [azurerm_resource_group.vms]

  name                = var.nics[0].virtual_network_name
  location            = var.location
  resource_group_name = var.nic_resource_group_name == "vmrg" ? var.resource_group_name : var.nic_resource_group_name
  address_space       = ["10.126.0.0/28"]

  subnet {
    name           = var.nics[0].subnet_name
    address_prefixes = ["10.126.0.0/28"]
  }

  tags = var.required_tags
}

#Deploy Key Vault, Access Policies, and Disk Encryption Set
module "Azure-GoldenKeyVault" {
  source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenKeyVault?ref=3.1.0"

  name                        = "${var.name}1-kv"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.vms.name
  enable_rbac_authorization   = false
  enabled_for_disk_encryption = true
  bypass_trusted_services     = true
  public_network_access       = true
  allowed_ip_rules            = ["170.48.0.0/16", "165.225.0.0/16", "208.242.0.0/16", "162.246.196.228/32"]
  initial_access_assignments = [{
    principal_id = "self"
    roles        = ["Key Vault Administrator"]
  }]

  required_tags = var.required_tags
}

resource "azurerm_key_vault_key" "cmk" {
  #Terraform is not figuring out dependencies well with module reference, so specifying
  depends_on = [module.Azure-GoldenKeyVault]

  name         = "${var.name}-key"
  key_vault_id = module.Azure-GoldenKeyVault.key_vault_id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]
}

resource "azurerm_disk_encryption_set" "des" {
  name                = "${var.name}-des"
  resource_group_name = azurerm_resource_group.vms.name
  location            = var.location
  key_vault_key_id    = azurerm_key_vault_key.cmk.id

  identity {
    type = "SystemAssigned"
  }

  tags = var.required_tags
}

resource "time_sleep" "delay_for_MI_prop" {
  depends_on      = [azurerm_disk_encryption_set.des]
  create_duration = "60s"
}

resource "azurerm_key_vault_access_policy" "desap" {
  depends_on = [time_sleep.delay_for_MI_prop]

  key_vault_id = module.Azure-GoldenKeyVault.key_vault_id
  tenant_id    = azurerm_disk_encryption_set.des.identity.0.tenant_id
  object_id    = azurerm_disk_encryption_set.des.identity.0.principal_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "WrapKey",
    "UnwrapKey",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign"
  ]
}

##################################
## Deploy Linux and Windows VMs ##
##################################
/*
resource "azurerm_marketplace_agreement" "cislicense" {
  publisher = "center-for-internet-security-inc"
  offer     = "cis-ubuntu"
  plan      = "cis-ubuntulinux2004-stig-gen1"
}
*/

module "Azure-GoldenVMs" {
  source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenVM.git?ref=2.1.1"

  providers = {
    azurerm     = azurerm
    azurerm.sig = azurerm.sig
  }
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_disk_encryption_set.des,
    azurerm_key_vault_access_policy.desap,
#    azurerm_mazurerm_marketplace_agreement.cislicense
  ]
  for_each = var.VMs

  resource_group_name     = azurerm_resource_group.vms.name
  nic_resource_group_name = var.nic_resource_group_name
  name                    = each.key
  required_tags           = var.required_tags
  required_data_tags      = var.required_data_tags
  nics                    = var.nics
  os_type                 = each.value.os_type
  image_name              = each.value.image_name
  image_version_id        = each.value.image_version_id
  size                    = each.value.size
  admin_username          = "azadmin"
  #This is not a secure way to pass the secret key, and should not be used for anything other than short-lived deployment testing
  admin_password         = each.value.admin_password
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
  data_disks             = each.value.data_disks
}


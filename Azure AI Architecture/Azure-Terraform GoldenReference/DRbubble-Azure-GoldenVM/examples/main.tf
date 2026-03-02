terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
  }
}

provider "azurerm" {
  subscription_id = local.dev_subscription_id
  features {}
}

locals {
  resource_group_name = "NewVMs-rg"
}

#######################################
# Build simple network to deploy into #
#######################################

#Change to golden vNet module
resource azurerm_virtual_network "vnet" {
    name = "vmgmtest-vnet"
    location = var.location
    resource_group_name = local.resource_group_name
    address_space = ["10.126.0.0/28"]

    subnet {
        name = "vmgmtest-snet"
        address_prefix = "10.126.0.0/28"
    }

    tags = var.required_tags
}

######################
## Deploy NewModule ##
######################

#Deploy NewModule in primary and redundant locations, with synchronization enabled 
module "Azure-Golden-VM-Module" {
  source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-Golden-VM.git"

  resource_group_name = "CriblDemo-rg"
  name = "CriblDemo01-vm"
  required_tags = {
        AssetOwner             = "james.brown@cigna.com"
        CostCenter             = "00000000"
        ServiceNowBA           = "00000000"
        ServiceNowAS           = "00000000"
        SecurityReviewID       = "00000000"
        DataSubjectArea        = "none"
        ComplianceDataCategory = "none"
        DataClassification     = "none"
        BusinessEntity         = "00000000"
        LineOfBusiness         = "00000000"
  }
  nics = [{
              subnet_name = "default-snet"
              virtual_network_name = "default_routable-vnet"
        }]
  os_type = "Linux"
  image_name = "CriblImageDefinition"
  size = "Standard_D4as_v4"
  admin_username = "azadmin"
  admin_password = #pass in securely
  source_image = {
        version = "latest"
  }
  publisher = "public-cloud-center-of-enablement"
  offer = "cis-ubuntu2004-l1"
  sku = "cis-ubuntu-linux-2004-l1"
  disk_encryption_set_id = "/subscriptions/e21aa9b2-7d66-4aa3-898d-503686e49ff6/resourceGroups/michael_s-rg/providers/Microsoft.Compute/diskEncryptionSets/ssevms-des"
  data_disks = [{
        name = "01"
        disk_size_gb = "50"
        storage_account_type = "Standard_LRS"
        lun = "10"
        caching = "ReadWrite"
      }]
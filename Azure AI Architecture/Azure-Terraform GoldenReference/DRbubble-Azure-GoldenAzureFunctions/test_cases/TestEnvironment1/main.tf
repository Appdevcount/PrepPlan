##################################################################
## Testing for Azure-GoldenKeyVault module typical deployment ##
##################################################################

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


######################
## Deploy NewModule ##
######################

#Deploy NewModule in primary and redundant locations, with synchronization enabled 
module azure_golden_function {
  source = var.source_code_storage_source

  name = "${var.name}-sa"
  resource_group_name = var.resource_group_name

  account_tier = "Standard"
  account_replication_type = "LRS"
  access_tier = "Hot"

  allowed_public_ips = var.allowed_public_ips

  allowed_subnet_ids = var.allowed_subnet_ids

  monitor_log_storage_account_id = var.monitor_log_storage_account_id

  tags = local.data_tags
}
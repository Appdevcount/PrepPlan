terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.87.0"
    }
  }
  #backend "azurerm" {
  #  resource_group_name  = "keyvault-test-rg"
  #  storage_account_name = "keyvaulttestdevdeploysa"
  #  container_name       = "tfstate"
  #  key                  = "kv.tfstate"
  #}
}

provider "azurerm" {
  skip_provider_registration = true
  features {
        key_vault {
          purge_soft_delete_on_destroy = false
        }
      }
}

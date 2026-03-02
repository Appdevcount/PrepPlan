terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "keyvault-test-rg"
    storage_account_name = "keyvaulttestdevdeploysa"
    container_name       = "tfstate"
    key                  = "kv.tfstate"
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

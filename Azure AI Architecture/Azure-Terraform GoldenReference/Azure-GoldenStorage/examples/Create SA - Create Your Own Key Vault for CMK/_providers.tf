terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.87.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
    storage_use_azuread = !var.shared_access_key_enabled
}


terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}
provider "azapi" {
  subscription_id = var.subscription_id
}


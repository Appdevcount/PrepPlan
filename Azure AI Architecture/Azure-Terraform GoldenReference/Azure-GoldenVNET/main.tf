terraform {
  required_version = ">= 1.4.4"

  required_providers {
    azurerm = "~> 3.43"
  }
}

data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "current_subscription" {}

data "azurerm_resource_group" "target_rg" {
  name = var.resource_group_name
}

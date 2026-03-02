##################################################################
## Testing for Azure-GoldenAppService module typical deployment ##
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

locals {
  vnet_name = "vmgmtest-vnet"
  snet_name = "vmgmtest-snet"
}

#################################################
# Build simple network to hold private endpoint #
#################################################

resource "azurerm_resource_group" "rg" {
  name      = var.resource_group_name
  location  = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  location            = var.location
  resource_group_name = resource.azurerm_resource_group.rg.name
  address_space       = ["10.126.0.0/28"]
  tags                = var.required_tags
}

resource "azurerm_subnet" "snet" {
  name                                           = local.snet_name
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["10.126.0.0/28"]
  enforce_private_link_endpoint_network_policies = true
}


######################
## Deploy NewModule ##
######################

#Deploy NewModule in primary and redundant locations, with synchronization enabled 
module "Azure-GoldenAppService" {
  source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenAppService.git?ref=2.0.0"
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_subnet.snet
  ]

  resource_group_name        = var.resource_group_name
  name                       = var.name
  pe_virtual_network_name    = local.vnet_name
  pe_subnet_name             = local.snet_name
  sku                        = var.sku
  kind                       = var.kind
  app_service_environment_id = var.app_service_environment_id
  app_settings               = var.app_settings
  client_affinity_enabled    = var.client_affinity_enabled
  client_cert_enabled        = var.client_cert_enabled
  connection_strings         = var.connection_strings
  auth_settings              = var.auth_settings
  site_config                = var.site_config
  ip_restriction             = var.ip_restriction
  scm_ip_restriction         = var.scm_ip_restriction
  cors_allowed_origins       = var.cors_allowed_origins
  storage_account            = var.storage_account
  logs                       = var.logs

  required_tags = var.required_tags
}

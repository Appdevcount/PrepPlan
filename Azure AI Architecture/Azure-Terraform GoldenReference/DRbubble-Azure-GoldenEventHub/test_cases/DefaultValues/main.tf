#############################################################
## Final unit-testing root module for Azure-GoldenEventHub ##
## Use Case shared cluster (Standard and Basic)            ##
#############################################################

terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.23"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  subscription_id = local.dev_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "sdbx"
  subscription_id = local.sdbx_subscription_id
  features {}
}

#Create a new resource group for Event Hub Namespaces
resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "rg-Azure-GoldenEventHub_unit_testing"
}

#Create a new virtual network with subnet for private endpoint
resource "azurerm_virtual_network" "endpoints" {
  name                = "vnet-EH_endpoints"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["100.124.120.0/24"]
  subnet {
    name           = "default"
    address_prefix = "100.124.120.0/25"
  }
}

resource "azurerm_subnet" "snendpoints" {
  name                                           = "endpoints"
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.endpoints.name
  address_prefixes                               = ["100.124.120.128/29"]
  enforce_private_link_endpoint_network_policies = true
}


################################
## Deploy namespaces and hubs ##
################################


## Test 2 -- simple single region case with default values, no policies (empty set passed in)
module "Azure-GoldenEventHub-TC2" {
  source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenEventHub.git?ref=2.0.0"

  name                = var.name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  pe_subnet_id        = azurerm_subnet.snendpoints.id

  event_hubs = {
    messages = {
      partition_count   = 12
      message_retention = 5
      consumer_groups   = []
      access_policies   = {}
    }
  }
  required_tags = var.required_tags
}

output "ns_name" {
  value = module.Azure-GoldenEventHub-TC2.ns_name
}

output "ns_id" {
  value = module.Azure-GoldenEventHub-TC2.ns_id
}

output "ns_identity" {
  value = module.Azure-GoldenEventHub-TC2.ns_identity
}

output "default_RootManageSharedAccessKey" {
  value     = module.Azure-GoldenEventHub-TC2.RootManageSharedAccessKey
  sensitive = true
}

output "private_endpoint_id" {
  value = module.Azure-GoldenEventHub-TC2.private_endpoint_id
}

output "drns_name" {
  value = module.Azure-GoldenEventHub-TC2.drns_name
}

output "drns_id" {
  value = module.Azure-GoldenEventHub-TC2.drns_id
}

output "drns_identity" {
  value = module.Azure-GoldenEventHub-TC2.drns_identity
}

output "drprivate_endpoint_id" {
  value = module.Azure-GoldenEventHub-TC2.drprivate_endpoint_id
}

output "eventhub_namespace_authorization_rule_id" {
  value = module.Azure-GoldenEventHub-TC2.eventhub_namespace_authorization_rule_id
}

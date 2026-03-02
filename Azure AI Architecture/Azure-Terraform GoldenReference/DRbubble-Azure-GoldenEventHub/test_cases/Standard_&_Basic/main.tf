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
  subscription_id = local.sdbx_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "dev"
  subscription_id = local.dev_subscription_id
  features {}
}


#Create a new resource group for Event Hub Namespaces
resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "rg-Azure-GoldenEventHub_unit_testing"
}

#Create a new resource group and virtual network to use a target for virtual network rule, and PE in a different subscription
resource "azurerm_resource_group" "rg2" {
  provider = azurerm.dev
  location = var.location
  name     = "rg-Azure-GoldenEventHub_unit_testing"
}

resource "azurerm_virtual_network" "vnet" {
  provider            = azurerm.dev
  name                = "vnet-ForTesting"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg2.name
  address_space       = ["100.124.124.0/24"]
  subnet {
    name           = "denied"
    address_prefix = "100.124.124.0/25"
  }
  tags = var.required_tags
}

resource "azurerm_subnet" "allowsnet" {
  provider             = azurerm.dev
  name                 = "allowed"
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["100.124.124.128/26"]
}

resource "azurerm_subnet" "remoteendpoints" {
  provider                                       = azurerm.dev
  name                                           = "remotemendpoints"
  resource_group_name                            = azurerm_resource_group.rg2.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["100.124.124.192/26"]
  enforce_private_link_endpoint_network_policies = true
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


#Create a new virtual network for private endpoint in DR region
resource "azurerm_virtual_network" "drendpoints" {
  count               = var.drlocation == null ? 0 : 1
  name                = "vnet-EH_drendpoints"
  location            = var.drlocation
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["100.124.121.0/24"]
  subnet {
    name           = "default"
    address_prefix = "100.124.121.0/25"
  }
  tags = var.required_tags
}

resource "azurerm_subnet" "sndrendpoints" {
  count                                          = var.drlocation == null ? 0 : 1
  name                                           = "drendpoints"
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.drendpoints[0].name
  address_prefixes                               = ["100.124.121.128/29"]
  enforce_private_link_endpoint_network_policies = true
}

#Create a Log Analytics Workspace for logging
resource "random_id" "rndm" {
  byte_length = 2
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "loglawevhunittest${random_id.rndm.dec}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Free"
  retention_in_days   = 7
  tags                = var.required_tags
}

#Create a storage account for logging
resource "azurerm_storage_account" "storage" {
  name                     = "logsaevhunittest${random_id.rndm.dec}"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.required_tags
}

#Create a basic Event Hub to be used in Test 4 for logging
module "LoggingEH" {
  source              = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenEventHub.git?ref=2.0.0"
  resource_group_name = azurerm_resource_group.rg.name
  name                = "goldenehtest-logging-eh"
  location            = var.location
  private_endpoints   = false

  event_hubs = {}

  required_tags = var.required_tags
}

#The EventHub module specifically prevents creation of a shared access policy with manage enabled, but logging
#to an event hub requires manage to be allowed, so creating policy outside module
resource "azurerm_eventhub_namespace_authorization_rule" "LoggingRule" {
  name                = "LoggingSharedAccessKey"
  namespace_name      = module.LoggingEH.ns_name
  resource_group_name = azurerm_resource_group.rg2.name
  listen              = true
  send                = true
  manage              = true
}


################################
## Deploy namespaces and hubs ##
################################

module "Azure-GoldenEventHub-Test" {
  source              = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenEventHub.git?ref=2.0.0"
  resource_group_name = azurerm_resource_group.rg.name
  name                = var.name
  location            = var.location
  private_endpoints   = var.private_endpoints
  pe_subnet_id        = var.private_endpoints ? azurerm_subnet.snendpoints.id : null

  dr_location     = var.drlocation == null ? null : var.drlocation
  pe_dr_subnet_id = var.drlocation == null ? null : azurerm_subnet.sndrendpoints[0].id

  allowed_subnet_ids = var.subnetrules ? [azurerm_subnet.allowsnet.id] : []
  allowed_ip_ranges  = var.allowed_ip_ranges


  auto_inflate_enabled     = var.auto_inflate_enabled
  maximum_throughput_units = var.maximum_throughput_units

  logging_enabled                              = var.logging_enabled
  log_storage_account_id                       = var.logstorage ? azurerm_storage_account.storage.id : null
  log_analytics_workspace_id                   = var.loganalytics ? azurerm_log_analytics_workspace.law.id : null
  log_eventhub_namespace_authorization_rule_id = var.logeh ? azurerm_eventhub_namespace_authorization_rule.LoggingRule.id : null

  namespace_shared_access_policies = var.namespace_shared_access_policies

  event_hubs = var.event_hubs

  required_tags = var.required_tags
}


output "ns_name" {
  value = module.Azure-GoldenEventHub-Test.ns_name
}

output "ns_id" {
  value = module.Azure-GoldenEventHub-Test.ns_id
}

output "ns_identity" {
  value = module.Azure-GoldenEventHub-Test.ns_identity
}

output "default_RootManageSharedAccessKey" {
  value     = module.Azure-GoldenEventHub-Test.RootManageSharedAccessKey
  sensitive = true
}

output "private_endpoint_id" {
  value = module.Azure-GoldenEventHub-Test.private_endpoint_id
}

output "drns_name" {
  value = module.Azure-GoldenEventHub-Test.drns_name
}

output "drns_id" {
  value = module.Azure-GoldenEventHub-Test.drns_id
}

output "drns_identity" {
  value = module.Azure-GoldenEventHub-Test.drns_identity
}

output "drprivate_endpoint_id" {
  value = module.Azure-GoldenEventHub-Test.drprivate_endpoint_id
}

output "eventhub_namespace_authorization_rule_id" {
  value = module.Azure-GoldenEventHub-Test.eventhub_namespace_authorization_rule_id
}

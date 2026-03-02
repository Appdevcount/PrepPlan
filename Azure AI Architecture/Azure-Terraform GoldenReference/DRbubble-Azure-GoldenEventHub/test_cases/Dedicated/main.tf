#############################################################
## Final unit-testing root module for Azure-GoldenEventHub ##
## Use Case Dedicated Cluster                              ##
#############################################################

/* Note - these tests were not automated through Terratest due to minimum run-time
   requirements for a dedicated event hub (4 hours). Tests were run manually
   during unit testing to verify successful deployment.

   Unit testing should typically use plan only instead of actual deployment. If
   dedicated event hub is deployed, it must be manually decomissioned after
   the 4 hour minimum is met.
*/

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

#Create a new resource group and virtual network to use a target for virtual network rule, in a different subscription
resource "azurerm_resource_group" "rg2" {
  provider = azurerm.dev
  location = local.location
  name     = "rg-Azure-GoldenEventHub_unit_testing"
}

resource "azurerm_virtual_network" "vnet" {
  provider            = azurerm.dev
  name                = "vnet-ForTesting"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg2.name
  address_space       = ["100.124.124.0/24"]
  subnet {
    name           = "denied"
    address_prefix = "100.124.124.128/25"
  }
  tags = local.tags
}

resource "azurerm_subnet" "allowsnet" {
  provider             = azurerm.dev
  name                 = "allowed"
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["100.124.124.0/25"]
}

#Create a new resource group for Event Hub Cluster and Namespaces, and create the dedicated cluster
resource "azurerm_resource_group" "rg" {
  location = local.location
  name     = "rg-Azure-GoldenEventHub_unit_testing"
}

resource "azurerm_eventhub_cluster" "cluster" {
  name                = "azuregoldeneventhubunittest01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = local.location
  sku_name            = "Dedicated_1"
}

#Create a new virtual network with subnet for private endpoint
resource "azurerm_virtual_network" "endpoints" {
  name                = "vnet-EH_endpoints"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["100.124.120.0/24"]
  subnet {
    name           = "default"
    address_prefix = "100.124.120.0/25"
  }
}

resource "azurerm_subnet" "endpoints" {
  name                                           = "endpoints"
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.endpoints.name
  address_prefixes                               = ["100.124.120.128/29"]
  enforce_private_link_endpoint_network_policies = true
}


#Create a new virtual network for private endpoint in DR region
resource "azurerm_virtual_network" "drendpoints" {
  name                = "vnet-EH_drendpoints"
  location            = local.drlocation
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["100.124.121.0/24"]
  subnet {
    name           = "default"
    address_prefix = "100.124.121.0/25"
  }
  tags = local.tags
}

resource "azurerm_subnet" "drendpoints" {
  name                                           = "drendpoints"
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.drendpoints.name
  address_prefixes                               = ["100.124.121.128/29"]
  enforce_private_link_endpoint_network_policies = true
}


#Create a basic Event Hub for logging in different subscription
module "LoggingEH" {
  source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenEventHub.git?ref=2.0.0"
  providers = {
    azurerm = azurerm.dev
  }
  resource_group_name = azurerm_resource_group.rg2.name
  name                = "eh-GoldenEventHub-unittest-Logging"
  private_endpoints   = false

  event_hubs    = {}
  required_tags = local.tags
}

resource "azurerm_eventhub_namespace_authorization_rule" "LoggingRuleT6" {
  provider            = azurerm.dev
  name                = "LoggingSharedAccessKeyT6"
  namespace_name      = module.LoggingEH.ns_name
  resource_group_name = azurerm_resource_group.rg2.name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_eventhub_namespace_authorization_rule" "LoggingRuleT7" {
  provider            = azurerm.dev
  name                = "LoggingSharedAccessKeyT7"
  namespace_name      = module.LoggingEH.ns_name
  resource_group_name = azurerm_resource_group.rg2.name
  listen              = true
  send                = true
  manage              = true
}

#####################################################
## Deploy namespaces and hubs in dedicated cluster ##
#####################################################

## Test 5 -- simple single region case with incompatible values passed in, no logging, no private endpoints, no policies
module "Azure-GoldenEventHub-TC1" {
  source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenEventHub.git?ref=2.0.0"

  name                 = "evhns-dedicated-simple"
  dedicated_cluster_id = azurerm_eventhub_cluster.cluster.id
  location             = local.location
  resource_group_name  = azurerm_resource_group.rg.name
  private_endpoints    = false

  #All of these values are incompatible with a dedicated cluster, and should be corrected by module logic
  sku                  = "Basic"
  capacity             = 1
  auto_inflate_enabled = true

  event_hubs = {
    messages = {
      partition_count   = 12
      message_retention = 1
      consumer_groups   = []
      access_policies   = {}
    }
  }
  required_tags = local.tags
}


## Test 6 -- single region case with all options, logging to event hub
module "Azure-GoldenEventHub-TC2" {
  source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenEventHub.git?ref=2.0.0"

  name                 = "evhns-dedicated-complex"
  dedicated_cluster_id = azurerm_eventhub_cluster.cluster.id
  location             = local.location
  resource_group_name  = azurerm_resource_group.rg.name
  private_endpoints    = false

  allowed_subnet_ids = [azurerm_subnet.allowsnet.id]
  allowed_ip_ranges  = ["100.64.0.0/10", "10.188.0.0/16"]

  logging_enabled                              = true
  log_eventhub_name                            = "diags"
  log_eventhub_namespace_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.LoggingRuleT6.id

  namespace_shared_access_policies = {
    auditpol = {
      send   = true
      listen = true
    }
  }

  event_hubs = {
    fe-messaging = {
      partition_count   = 30
      message_retention = 3
      consumer_groups   = ["iotios", "iotand", "feapps"]
      access_policies = {
        device_policy = {
          send   = true
          listen = false
        },
        app_policy = {
          send   = false
          listen = true
        }
      }
    },
    be-messaging = {
      partition_count   = 12
      message_retention = 5
      consumer_groups   = ["beapps"]
      access_policies   = {}
    },
    offloading = {
      partition_count   = 12
      message_retention = 5
      consumer_groups   = ["olgroup"]
      access_policies = {
        ol_policy = {
          send   = true
          listen = true
        }
      }
    }
  }

  required_tags = local.tags
}


## Test 7 -- Geo-redundant with all config options specified, no private endpoints, DR to standard tier namespace
##           NOTE: ">terraform destroy" usually fails breaking the pairing, requiring manual clean-up
module "Azure-GoldenEventHub-TC3" {
  source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenEventHub.git?ref=2.0.0"

  name                 = "evhns-dedicated-complex-georedundant"
  dedicated_cluster_id = azurerm_eventhub_cluster.cluster.id
  location             = local.location
  resource_group_name  = azurerm_resource_group.rg.name
  pe_subnet_id         = azurerm_subnet.endpoints.id

  dr_location     = local.drlocation
  pe_dr_subnet_id = azurerm_subnet.drendpoints.id

  allowed_subnet_ids = [azurerm_subnet.allowsnet.id]
  allowed_ip_ranges  = ["100.64.0.0/10", "10.188.0.0/16"]

  logging_enabled                              = true
  log_eventhub_namespace_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.LoggingRuleT7.id

  namespace_shared_access_policies = {
    auditpol = {
      send   = true
      listen = true
    }
  }

  event_hubs = {
    fe-messaging = {
      partition_count   = 30
      message_retention = 3
      consumer_groups   = ["iotios", "iotand", "feapps"]
      access_policies = {
        device_policy = {
          send   = true
          listen = false
        },
        app_policy = {
          send   = false
          listen = true
        }
      }
    },
    be-messaging = {
      partition_count   = 12
      message_retention = 5
      consumer_groups   = ["beapps"]
      access_policies   = {}
    },
    offloading = {
      partition_count   = 12
      message_retention = 5
      consumer_groups   = ["olgroup"]
      access_policies = {
        ol_policy = {
          send   = true
          listen = true
        }
      }
    }
  }

  required_tags = local.tags
}

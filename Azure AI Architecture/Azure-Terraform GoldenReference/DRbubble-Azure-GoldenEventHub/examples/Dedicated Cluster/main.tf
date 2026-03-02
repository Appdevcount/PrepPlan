####################################################
## Azure-GoldenEventHub Dedicated Cluster example ##
####################################################

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
  subscription_id = "e21aa7b2-7c66-4aa3-898d-502686e59ff6"
  features {}
}

locals {
  location            = "EastUS"
  resource_group_name = "rg-KeyApplication"
  tags = {
    AssetOwner       = "<E-mail of asset owner>"
    CostCenter       = "<Cost Center>"
    ServiceNowBA     = "<Service Now BA>"
    ServiceNowAS     = "<Service Now AS>"
    SecurityReviewID = "<Security Review ID>"
  }
}

#Get an existing subnet for Private Endpoint
#   IMPORTANT - This subnet must have private link policies enabled
data "azurerm_subnet" "pvtendpoint" {
  name                 = "snet-endpoints"
  virtual_network_name = "vnet-routable-network"
  resource_group_name  = local.resource_group_name
}

#Get an existing subnet that will be allowed to access Event Hub
data "azurerm_subnet" "allowsubnet" {
  name                 = "snet-default"
  virtual_network_name = "vnet-main-network"
  resource_group_name  = "rg-BigData"
}

#Get existing Event Hub where logging should be sent
data "azurerm_eventhub_namespace_authorization_rule" "logging" {
  name                = "rule-sendlogs"
  resource_group_name = "rg-itprod-monitoring"
  namespace_name      = "evhns-logging"
}

#Create a new Dedicated Event Hub cluster
resource "azurerm_eventhub_cluster" "cluster" {
  name                = "cigeventhubkeyapp122821"
  resource_group_name = local.resource_group_name
  location            = local.location
  sku_name            = "Dedicated_1"
}

# Deploy namespaces and hubs in dedicated cluster 

module "Azure-GoldenEventHub-TC2" {
  source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenEventHub.git?ref=2.0.0"

  name                 = "evhns-KeyApp_messaging"
  dedicated_cluster_id = azurerm_eventhub_cluster.cluster.id
  location             = azurerm_eventhub_cluster.cluster.location
  resource_group_name  = azurerm_eventhub_cluster.cluster.resource_group_name

  allowed_subnet_ids = [azurerm_subnet.allowsubnet.id]
  allowed_ip_ranges  = ["100.64.0.0/10", "10.188.0.0/16"]

  logging_enabled                              = true
  log_eventhub_namespace_authorization_rule_id = data.azurerm_eventhub_namespace_authorization_rule.logging.id

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
    required_tags = local.tags
  }
}

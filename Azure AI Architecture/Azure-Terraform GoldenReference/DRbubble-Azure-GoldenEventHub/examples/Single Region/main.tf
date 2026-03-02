################################################
## Azure-GoldenEventHub Single Region example ##
################################################

terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
        version = "~> 2.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "~> 1.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.0"
    }
    #backend "<...>" {}
  }
}

provider "azurerm" {
  subscription_id               = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  features {}
}

locals {
  location                      = "EastUS"
  resource_group_name           = "rg-health_goal_tracking_app"
  tags = {
    AssetOwner                  = "<E-mail of asset owner>"
    CostCenter                  = "<Cost Center>"
    ServiceNowBA                = "<Service Now BA>"
    ServiceNowAS                = "<Service Now AS>"
    SecurityReviewID            = "<Security Review ID>"
  }  
}

#Get ID of subnets that will be allowed to access Event Hub
data azurerm_subnet "snet1" {
  name                          = "snet-presentation_tier"
  virtual_network_name          = "vnet-AIApps7"
  resource_group_name           = "rg-AIApps_Infrastructure"
  }
}

data azurerm_subnet "snet2" {
  name                          = "snet-logic_tier"
  virtual_network_name          = "vnet-AIApps7"
  resource_group_name           = "rg-AIApps_Infrastructure"
  }
}

#Create a Log Analytics Workspace
resource "random_id" "rndm" {
  byte_length                   = 8
}
resource azurerm_log_analytics_workspace "law" {
    name                        = "logsagehdeploymnettest${random_id.rndm.id}"
    location                    = var.location
    resource_group_name         = local.resource_group_name
    sku                         = "Free"
    retention_in_days           = 7
}

#Deploy Event Hub
module "Azure-GoldenEventHub" {
    source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenEventHub.git?ref=2.0.0"

    location                    = local.location
    resource_group_name         = local.resource_group_name
    name                        = "ageh-deployment-test"
    sku                         = "Standard"
    allowed_subnet_ids          = [data.azurerm_subnet.snet1.id, data.azurerm_subnet.snet2.id]
    allowed_ip_ranges           = ["192.168.12.0/24"]
    
    logging_enabled             = true
    log_analytics_workspace_id  = azurerm_log_analytics_workspace.law.id

    namespace_shared_access_policies = {
      AppMustHavePol1 = {
          send                  = true
          listen                = true
      },
      AppMustHavePol2 = {
          send                  = false
          listen                = true
      }
  }

    event_hubs = {
        apphub1 = {
            partition_count     = 5
            message_retention   = 7
	          consumer_groups = ["cg-hub1cg1", "cg-hub1cg2"]
            access_policies = {}
        },
        apphub2 = {
            partition_count     = 10
            message_retention   = 7
    	      consumer_groups = []
            access_policies = {
                ap-hub2pol1 = {
                    send        = true
                    listen      = true
                },
                ap-hub2pol2 = {
                    send        = false
                    listen      = true
                }
            }
        }
    }
    required_tags                        = local.tags
}
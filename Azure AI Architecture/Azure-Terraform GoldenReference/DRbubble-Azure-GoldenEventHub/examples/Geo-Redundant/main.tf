################################################
## Azure-GoldenEventHub Geo-redundant example ##
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
    backend "azurerm" {
      resource_group_name = "rg-AIApps_Infrastructure"
      storage_account_name = "aiappstfstate"
      container_name = "tstate"
      key = "terraform.tfstate"
    }
  }
}

provider "azurerm" {
  subscription_id               = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  features {}
}

locals {
  location                      = "EastUS"
  drlocation                    = "WestUS"
  resource_group_name           = "rg-AI_risk_factors"
  tags = {
    AssetOwner       = "<E-mail of asset owner>"
    CostCenter       = "<Cost Center>"
    ServiceNowBA     = "<Service Now BA>"
    ServiceNowAS     = "<Service Now AS>"
    SecurityReviewID = "<Security Review ID>"
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

#Create Virtual Networks in primary and DR regions for Private Endpoints
resource azurerm_virtual_network "endpoints" {
  name                          = "vnet-EH_endpoints"
  location                      = local.location
  resource_group_name           = local.resource_group_name
  address_space                 = ["100.124.120.128/29"]
  tags                          = local.tags
}

resource azurerm_subnet "snendpoints" {
  name                          = "endpoints"
  resource_group_name           = local.resource_group_name
  virtual_network_name          = azurerm_virtual_network.endpoints.name
  address_prefixes              = ["100.124.120.128/29"]
  enforce_private_link_endpoint_network_policies = true
}

resource azurerm_virtual_network "drendpoints" {
  name                          = "vnet-EH_drendpoints"
  location                      = local.drlocation
  resource_group_name           = local.resource_group_name
  address_space                 = ["100.124.121.128/29"]
  tags                          = local.tags
}

resource azurerm_subnet "sndrendpoints" {
  name                          = "drendpoints"
  resource_group_name           = local.resource_group_name
  virtual_network_name          = azurerm_virtual_network.drendpoints.name
  address_prefixes              = ["100.124.121.128/29"]
  enforce_private_link_endpoint_network_policies = true
}


#Deploy Event Hub
module "Azure-GoldenEventHub" {
    source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenEventHub.git?ref=2.0.0"

    location                    = local.location
    resource_group_name         = local.resource_group_name
    name                        = "evhns-AI_risk_factors"
    sku                         = "Standard"
    allowed_subnet_ids          = [data.azurerm_subnet.snet1.id, data.azurerm_subnet.snet2.id]
    allowed_ip_ranges           = ["192.168.12.0/24"]
    
    event_hubs = {
        apphub1 = {
            partition_count     = 5
            message_retention   = 7
	          consumer_groups     = ["cg-hub1cg1", "cg-hub1cg2"]
            access_policies     = {}
        },
        apphub2 = {
            partition_count     = 10
            message_retention   = 7
    	      consumer_groups     = []
            access_policies     = {}
            }
        }
    }

    required_tags                        = local.tags
}
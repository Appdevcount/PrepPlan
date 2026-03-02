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
  subscription_id = "021aa9b2-0000-xxxx-0000-503686e49f00"
  features {}
}

##########################################
# Build network to hold private endpoint #
##########################################

module "Azure-GoldenVNET" {
  source      = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenVNET.git?ref=1.0.0"
  location    = "eastus"
  rg_name     = "NewWebApp-rg"
  Application = "NewWebApp"
  vnetCIDR    = "10.1.2.0/24"
  Production  = false
  cigna_tags  = var.required_tags
  subnets = {
      PESubnet = "10.1.2.0/25"
  }
}

######################
## Deploy NewModule ##
######################

#Deploy NewModule in primary and redundant locations, with synchronization enabled 
module "Azure-GoldenAppService" {
  source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenAppService.git?ref=2.0.0"
  depends_on = [
    module.Azure-GoldenVNET
  ]

  location                  = "eastus"
  resource_group_name       = "NewWebApp-rg" 
  name                      = "NewWebApp"
  pe_virtual_network_name   = "NewWebApp-vnet"
  pe_subnet_name            = "PESubnet-subnet"
  sku                       = "P2V3"
  kind                      = "Linux"

  required_tags = {
    AssetOwner        = "dana.williams@cigna.com"
    CostCenter        = "0009999"
    ServiceNowAS      = "0000000"
    ServiceNowBA      = "0800999"
    SecurityReviewID  = "00000000"  }

  app_settings = {
    WEBSITE_PRIVATE_EXTENSIONS          = "0", 
    WEBSITE_SLOT_MAX_NUMBER_OF_TIMEOUTS = "4"
    WEBSITE_WARMUP_PATH                 = "/ready"
  }

  connection_strings = [{
    name                    = "Database"
    type                    = "SQLServer"
    value                   = "Server=tcp:oereg21-sql.database.windows.net;Initial Catalog=oereg21-db;Integrated Security=SSPI;Encrypt=True"
  }]

  site_config = {
    linux_fx_version        = "NODE|14-lts"
    http2_enabled           = "true"
  }

  ip_restriction = [{
    type                    = "ip_address"
    name                    = "OE Team Range 1"
    priority                = 5
    action                  = "Allow"
    address                 = "10.10.10.0/24"
    },
    {
    type                    = "ip_address"
    name                    = "OE Team Range 2"
    priority                = 6
    action                  = "Allow"
    address                 = "10.10.20.0/24"
  }]

  scm_ip_restriction [{
    type                    = "ip_address"
    name                    = "Deployment worker"
    priority                = 10
    action                  = "Allow"
    address                 = "100.1.1.213/32"
  }]
}

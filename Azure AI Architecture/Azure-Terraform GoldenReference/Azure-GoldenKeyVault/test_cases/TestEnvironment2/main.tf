##########################################################
## Testing for Azure-GoldenKeyVault module              ##
##    Deploy with virtual network and private endpoint. ##
##########################################################

terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
  }
}

# Have to test this in sandbox, since permissions to set IAM roles not granted in dev
provider "azurerm" {
  subscription_id = local.sdbx_subscription_id
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-rg"
  location = var.location
}

resource "azurerm_private_dns_zone" "dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
}

###########################################
## Deploy new vNET for Private Endpoints ##
###########################################

module "Azure-GoldenVNET" {
  source = "git::https://github.sys.cigna.com/cigna/Azure-GoldenVNET.git"
  depends_on = [
    azurerm_resource_group.rg,
    azurerm_private_dns_zone.dns
  ]

  location = var.location
  rg_name  = azurerm_resource_group.rg.name
  #GoldenVNET module will postpend resource type designators to this name
  Application   = var.name
  vnetCIDR      = "10.37.104.0/24"
  Production    = false
  dns_zone_name = resource.azurerm_private_dns_zone.dns.name
  dns_zone_rg   = azurerm_resource_group.rg.name

  required_tags = var.required_tags

  subnets = {
    private    = "10.37.104.0/26"
    integrated = "10.37.104.64/26"
  }

  Endpoints = ["Microsoft.KeyVault"]
}


######################
## Deploy Key Vault ##
######################

module "Azure-GoldenKeyVault" {
  source = "git@github.sys.cigna.com:cigna/Azure-GoldenKeyVault.git?ref=3.1.2"

  resource_group_name             = azurerm_resource_group.rg.name
  name                            = "${var.name}-kv"
  enable_rbac_authorization       = var.enable_rbac_authorization
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  initial_access_assignments      = var.initial_access_assignments
  allowed_ip_rules                = var.allowed_ip_rules

  private_endpoint_ids = [{
    subnet_id            = module.Azure-GoldenVNET.subnets.private.id
    private_dns_zone_ids = [azurerm_private_dns_zone.dns.id]
  }]

  service_endpoint_ids = [module.Azure-GoldenVNET.subnets.integrated.id]

  required_tags = var.required_tags
}

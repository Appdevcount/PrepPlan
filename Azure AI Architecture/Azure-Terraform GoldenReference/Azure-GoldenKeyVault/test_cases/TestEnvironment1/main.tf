##################################################################
## Testing for Azure-GoldenKeyVault module typical deployment ##
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

# Have to test this in sandbox, since permissions to set IAM roles not granted in dev
provider "azurerm" {
  subscription_id = local.sdbx_subscription_id
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

######################
## Deploy NewModule ##
######################

resource "azurerm_resource_group" "testrg" {
  name     = var.resource_group_name
  location = var.location
}

module "Azure-GoldenKeyVault" {
  source = "git@github.sys.cigna.com:cigna/Azure-GoldenKeyVault.git?ref=3.1.0"

  name                        = var.name
  location                    = var.location
  resource_group_name         = azurerm_resource_group.testrg.name
  enable_rbac_authorization   = var.enable_rbac_authorization
  enabled_for_disk_encryption = var.enabled_for_disk_encryption
  allowed_ip_rules            = var.allowed_ip_rules
  private_endpoints           = var.private_endpoints
  service_endpoints           = var.service_endpoints
  initial_access_assignments  = var.initial_access_assignments

  required_tags = var.required_tags
}

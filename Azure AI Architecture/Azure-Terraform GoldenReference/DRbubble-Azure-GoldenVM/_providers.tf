terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">= 2.0"
      configuration_aliases = [azurerm.sig]
    }
  }

  /*
###  IMPORTANT! This provider block must be included in the calling module.  ###

provider "azurerm" {
  #Subscription holding Shared Image Gallery
  alias           = "sig"
  subscription_id = "9f7af41c-8074-4bc0-8cea-09b846ffc3f7"
  features {}
}

Also, the following required provider must be included in the terraform block.

  configuration_aliases = [azurerm.sig]

Example:

terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">= 2.0"
      configuration_aliases = [azurerm.sig]
    }
  }
}

provider "azurerm" {
  subscription_id = local.dev_subscription_id
  features {}
}

provider "azurerm" {
  #Subscription holding Shared Image Gallery
  alias           = "sig"
  subscription_id = "9f7af41c-8074-4bc0-8cea-09b846ffc3f7"
  features {}
}
*/

}

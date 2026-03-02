###########################################################
## Testing for Azure-GoldenNewModule typical environment ##
###########################################################

terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.23"
    }
  }
}

provider "azurerm" {
  subscription_id = local.dev_subscription_id
  features {}
}

##########################################
# Build environment <simple description> #
##########################################

  # Build required environment to support test case(s)
  <...>


#################################
## Deploy <simple description> ##
#################################

module "Azure-GoldenNewModule" {
  source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenNewModule.git?ref=v0.1.0"

  Call module with reference to variables in test variables file(s)
  <...>
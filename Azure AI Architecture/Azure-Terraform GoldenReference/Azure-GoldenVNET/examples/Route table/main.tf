provider "azurerm" {
  features { }
}
module "virtual_network" {
  #source                  = "git::ssh://git@ssh.dev.azure.com/v3/eviCoreDev/Reusable%20Code/Azure-GoldenVNET?ref=v2.0.8"
  source                  = "../../"
  application             = var.application
  resource_group_name     = var.rg_name
  location                = var.location
  vnetcidr                = var.vnetcidr
  subnets                 = var.subnets
  required_tags           = var.required_tags
  production              = var.production
  flow_storage_id         = var.flow_storage_id

}

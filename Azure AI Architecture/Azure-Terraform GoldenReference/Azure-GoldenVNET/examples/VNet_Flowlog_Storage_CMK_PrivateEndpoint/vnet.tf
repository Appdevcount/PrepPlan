provider "azurerm" {
  features { }
}
module "virtual_network" {
  depends_on = [module.golden_storage_account_module]
  source                         = "git::ssh://git@ssh.dev.azure.com/v3/eviCoreDev/Reusable%20Code/Azure-GoldenVNET?ref=v2.0.8"
  application                    = var.application
  resource_group_name            = var.rg_name
  location                       = var.location
  environment                    = var.environment 
  vnetcidr                       = var.vnetcidr
  subnets                        = var.subnets
  required_tags                  = var.required_tags
  production                     = var.production
  flow_storage_id                = module.golden_storage_account_module.storage_account_id
  monitor_log_storage_account_id = module.golden_storage_account_module.storage_account_id

  #Following optional variables can be used to override default resource suffix name
  vnet_suffix_name               = var.vnet_suffix_name #Override default value. Empty string is allowed
  #nontroutable_vnet_suffix_name    = "nonroutable-vnet" #Override default value. Empty string is allowed
  subnet_suffix_name             = var.subnet_suffix_name #Override default value. Empty string is allowed
  #nonroutable_subnet_suffix_name   = "" #Override default value. Empty string is allowed
  #nsg_suffix_name                  = "nsg" #Override default value. Empty string is allowed
  #nsg_nonroutable_suffix_name      = "nonroutable-nsg" #Override default value. Empty string is allowed
  #flow_log_suffix_name             = "" #Override default value. Empty string is allowed
  #nonroutable_flow_log_suffix_name = "" #Override default value. Empty string is allowed
}
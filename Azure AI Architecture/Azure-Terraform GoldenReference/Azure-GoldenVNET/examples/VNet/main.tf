provider "azurerm" {
  features { }
}
module "virtual_network" {
  # Note: there is a bug in v1.1.9 where vnetcidr is expected to be both a string and a list of strings. In v1.1.8 it can be a string.
  #source                       = "git::ssh://git@ssh.dev.azure.com/v3/eviCoreDev/Reusable%20Code/Azure-GoldenVNET?ref=v2.0.8"
  source                         = "../../"
  application                    = var.application
  resource_group_name            = var.rg_name
  location                       = var.location
  vnetcidr                       = var.vnetcidr
  subnets                        = var.subnets
  required_tags                  = var.required_tags
  production                     = var.production
  flow_storage_id                = var.flow_storage_id
  monitor_log_storage_account_id = var.monitor_log_storage_account_id 

  #Following optional variables can be used to override default resource suffix name
  #vnet_suffix_name                 = "vnet" #Override default value. Empty string is allowed
  #nontroutable_vnet_suffix_name    = "nonroutable-vnet" #Override default value. Empty string is allowed
  subnet_suffix_name               = "" #Override default value. Empty string is allowed
  #nonroutable_subnet_suffix_name   = "" #Override default value. Empty string is allowed
  #nsg_suffix_name                  = "nsg" #Override default value. Empty string is allowed
  #nsg_nonroutable_suffix_name      = "nonroutable-nsg" #Override default value. Empty string is allowed
  #flow_log_suffix_name             = "" #Override default value. Empty string is allowed
  #nonroutable_flow_log_suffix_name = "" #Override default value. Empty string is allowed
}
data "azurerm_client_config" "current" {}

#Get Subnet used for Private Endpoints
data "azurerm_subnet" "private_endpoint_subnet" {
  depends_on = [ module.virtual_network ]
  name                 = format("%s%s%s%s", var.application, "-" ,"private_endpoints", var.subnet_suffix_name)
  virtual_network_name = format("%s%s%s%s", var.environment, "-" ,var.application, var.vnet_suffix_name)
  resource_group_name  = var.rg_name
}

#Key Vault to add CMK support
data "azurerm_key_vault" "vault" {
  name                = "kv-cmk-poc-101010"
  resource_group_name = "tb-rsg-keyvault-poc"
}

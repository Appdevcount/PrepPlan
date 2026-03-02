resource "azurerm_network_security_group" "default" {
  count               = length(var.subnets) > 0 ? 1 : 0
  name                = format("%s%s", var.application, var.nsg_suffix_name)
  location            = var.location
  resource_group_name = data.azurerm_resource_group.target_rg.name

  tags = local.tags

}

resource "azurerm_network_security_group" "default-nonroutable" {
  count               = length(var.nonRoutableSubnets) > 0 ? 1 : 0
  name                = format("%s%s", var.application, var.nsg_nonroutable_suffix_name)
  location            = var.location
  resource_group_name = data.azurerm_resource_group.target_rg.name

  tags = local.tags

}

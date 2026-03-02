output "current_subscription_display_name" {
  value = data.azurerm_subscription.current_subscription.display_name
}

output "vnet" {
  value = length(var.subnets) > 0 ? azurerm_virtual_network.goldenVNET : []
}

output "vnet_nonroutable" {
  value = length(var.nonRoutableSubnets) > 0 ? azurerm_virtual_network.goldenVNET_nonroutable : []
}

output "subnets" {
  value = { for k, v in azurerm_subnet.goldenVNET_sub : k => v }
}

output "subnets_nonroutable" {
  value = { for k, v in azurerm_subnet.goldenVNET_sub_nonrt : k => v }
}

output "sg_id" {
  value = length(var.subnets) > 0 ? azurerm_network_security_group.default[0].id : null
}

output "nonroutable_sg_id" {
  value = length(var.nonRoutableSubnets) > 0 ? azurerm_network_security_group.default-nonroutable[0].id : null
}

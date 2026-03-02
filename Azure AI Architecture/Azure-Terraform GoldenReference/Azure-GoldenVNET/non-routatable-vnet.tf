locals {

  nonroutable_subnet_names = {
    for subnet_name, subnet_cidr in var.nonRoutableSubnets :
    subnet_name => "${contains(local.protected_subnet_names, subnet_name) ? subnet_name : format("%s%s%s%s", var.application, "-", subnet_name, "-nonroutable-subnet")}"
  }
}

resource "azurerm_virtual_network" "goldenVNET_nonroutable" {
  count               = length(var.nonRoutableSubnets) > 0 ? 1 : 0
  name                = length(local.vnet_prefix_name) > 0 ? format("%s%s%s", local.vnet_prefix_name, var.application, var.nonroutable_vnet_suffix_name) : format("%s%s", var.application, var.nonroutable_vnet_suffix_name)
  resource_group_name = data.azurerm_resource_group.target_rg.name
  location            = var.location
  address_space       = var.nonroutablevnetcidr
  tags                = local.tags

  lifecycle {

    precondition {
      condition = length(var.nonRoutableSubnets) > 0 ? alltrue([
                                                                for a in var.nonroutablevnetcidr : can(cidrnetmask(a))
                                                               ]) : true
    error_message = "Non-routable VNet CIDRs must have valid IPv4 CIDR block addresses."
   }

  }
}

resource "azurerm_subnet" "goldenVNET_sub_nonrt" {
  for_each = var.nonRoutableSubnets
  name                                      = format("%s%s%s%s", var.application, "-", each.key, var.nonroutable_subnet_suffix_name)
  virtual_network_name                      = azurerm_virtual_network.goldenVNET_nonroutable[0].name
  resource_group_name                       = data.azurerm_resource_group.target_rg.name
  address_prefixes                          = each.value.address_prefixes
  service_endpoints                         = each.value.service_endpoints
  private_endpoint_network_policies_enabled = each.value.private_endpoint_network_policies_enabled

  dynamic "delegation" {
    for_each = each.value.delegation_name != null ? [1] : []
    content {
      name = each.value.delegation_name
      service_delegation {
        name    = each.value.service_delegation_name
        actions = each.value.service_delegation_actions
      }
    }
  }

}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc_nonrt" {
  depends_on = [azurerm_subnet.goldenVNET_sub_nonrt, azurerm_network_security_group.default-nonroutable]
  for_each = {
    for k, v in var.nonRoutableSubnets : k => v
    if v.managednsg == false
  }

  subnet_id                 = azurerm_subnet.goldenVNET_sub_nonrt[each.key].id
  network_security_group_id = azurerm_network_security_group.default-nonroutable[0].id
}

##########Do we need to add any of the gateway settings?##############
resource "time_sleep" "wait_30_seconds" {
  depends_on = [azurerm_virtual_network.goldenVNET, azurerm_virtual_network.goldenVNET_nonroutable]

  create_duration = "30s"
}

resource "azurerm_virtual_network_peering" "Routable_to_Nonroutable" {
  count                     = var.enable_nonroutable_peering && length(var.nonRoutableSubnets) > 0 ? 1 : 0
  depends_on                = [time_sleep.wait_30_seconds]
  name                      = "Routable_to_Nonroutable"
  resource_group_name       = data.azurerm_resource_group.target_rg.name
  virtual_network_name      = azurerm_virtual_network.goldenVNET[0].name
  remote_virtual_network_id = azurerm_virtual_network.goldenVNET_nonroutable[0].id

  lifecycle {

    precondition {
      condition     = var.enable_nonroutable_peering ? length(var.nonRoutableSubnets) > 0 && length(var.subnets) > 0 : true
      error_message = "Both routable and non-routable vnets must be created in order to create vnet peering"
    }

  }
}

resource "azurerm_virtual_network_peering" "NonRoutable_to_Routable" {
  count                     = var.enable_nonroutable_peering && length(var.nonRoutableSubnets) > 0 ? 1 : 0
  depends_on                = [time_sleep.wait_30_seconds]
  name                      = "NonRoutable_to_Routable"
  resource_group_name       = data.azurerm_resource_group.target_rg.name
  virtual_network_name      = azurerm_virtual_network.goldenVNET_nonroutable[0].name
  remote_virtual_network_id = azurerm_virtual_network.goldenVNET[0].id

  lifecycle {

    precondition {
      condition     = var.enable_nonroutable_peering ? length(var.nonRoutableSubnets) > 0 && length(var.subnets) > 0 : true
      error_message = "Both routable and non-routable vnets must be created in order to create vnet peering"
    }

  }
}


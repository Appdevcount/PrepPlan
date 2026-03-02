locals {

  tenant_dns_servers = lookup(var.dns_servers, data.azurerm_client_config.current.tenant_id)
  environment_dns    = lookup(local.tenant_dns_servers, local.environment_type)
  dns_servers        = lookup(local.environment_dns, var.location, null) 
  
  subnet_names = {
    for subnet_name, subnet_cidr in var.subnets :
    subnet_name => "${contains(local.protected_subnet_names, subnet_name) ? subnet_name : format("%s%s%s%s", var.application, "-", subnet_name, var.subnet_suffix_name)}"
  }
}

resource "azurerm_virtual_network" "goldenVNET" {
  count               = length(var.subnets) > 0 ? 1 : 0
  name                = length(local.vnet_prefix_name) > 0 ? format("%s%s%s", local.vnet_prefix_name, var.application, var.vnet_suffix_name) : format("%s%s", var.application, var.vnet_suffix_name)
  resource_group_name = data.azurerm_resource_group.target_rg.name
  location            = var.location
  address_space       = var.vnetcidr
  dns_servers         = local.dns_servers

  tags = local.tags

  lifecycle {

    precondition {
      condition = length(var.subnets) > 0 ? alltrue([
                                                      for a in var.vnetcidr : can(cidrnetmask(a))
                                                    ]) : true
    error_message = "Routable VNet CIDRs must have valid IPv4 CIDR block addresses."
   }

  }

}

resource "azurerm_subnet" "goldenVNET_sub" {
  for_each                                  = var.subnets
  name                                      = local.subnet_names[each.key]
  virtual_network_name                      = azurerm_virtual_network.goldenVNET[0].name
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


# The var.subnets.managednsg value set to 'true' will prevent default NSG association
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  depends_on = [azurerm_subnet.goldenVNET_sub, azurerm_network_security_group.default]
  for_each = {
    for k, v in var.subnets : k => v
    if v.managednsg == false
  }

  subnet_id                 = azurerm_subnet.goldenVNET_sub[each.key].id
  network_security_group_id = azurerm_network_security_group.default[0].id
}

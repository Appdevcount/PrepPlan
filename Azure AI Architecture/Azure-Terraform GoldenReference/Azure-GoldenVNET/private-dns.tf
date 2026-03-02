locals {
  create_dns_zone_link = length(var.dns_zone_rg) > 0 && length(var.dns_zone_name) > 0 
  allow_private_dns_zone_link = data.azurerm_client_config.current.tenant_id != "595de295-db43-4c19-8b50-183dfd4a3d06"
}

data "azurerm_private_dns_zone" "dns_zone" {
  count               = local.create_dns_zone_link ? 1 : 0
  name                = var.dns_zone_name 
  resource_group_name = var.dns_zone_rg

  lifecycle {
      precondition {
        condition     = local.allow_private_dns_zone_link 
        error_message = "Private DNS Zone Link feature not available for routable vnet on eviCore tenant."
      }
  }  
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  count                 = local.create_dns_zone_link ? 1 : 0
  depends_on            = [azurerm_virtual_network.goldenVNET]

  name                  = "${var.application}-vnet-link"
  resource_group_name   = data.azurerm_private_dns_zone.dns_zone[0].resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.dns_zone[0].name
  virtual_network_id    = azurerm_virtual_network.goldenVNET[0].id
  registration_enabled  = true

  tags = local.tags

  lifecycle {
      precondition {
        condition     = local.allow_private_dns_zone_link
        error_message = "Private DNS Zone Link feature not available for routable vnet on eviCore tenant."
      }
  }
}
data "azurerm_virtual_network" "pe_vnet" {
  name                = var.pe_virtual_network_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "pe_subnet" {
  name                 = var.pe_subnet_name
  virtual_network_name = var.pe_virtual_network_name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_private_dns_zone" "dnsprivatezone" {
  count               = upper(substr(var.sku, 0, 1)) == "P" ? 1 : 0
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnszonelink" {
  count                 = upper(substr(var.sku, 0, 1)) == "P" ? 1 : 0
  name                  = "dnszonelink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dnsprivatezone[0].name
  virtual_network_id    = data.azurerm_virtual_network.pe_vnet.id
  tags                  = local.tags
}

resource "azurerm_private_endpoint" "privateendpoint" {
  count               = upper(substr(var.sku, 0, 1)) == "P" ? 1 : 0
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.pe_subnet.id

  private_dns_zone_group {
    name                 = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsprivatezone[0].id]
  }

  private_service_connection {
    name                           = "privateendpointconnection"
    private_connection_resource_id = azurerm_app_service.webapp.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
  tags = local.tags
}
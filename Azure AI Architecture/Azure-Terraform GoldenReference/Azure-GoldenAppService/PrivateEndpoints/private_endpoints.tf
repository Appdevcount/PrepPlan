locals {
  enable_private_dns_zone_group = data.azurerm_client_config.current.tenant_id != "595de295-db43-4c19-8b50-183dfd4a3d06"
}

# Create Private Endpoint
resource "azurerm_private_endpoint" "endpoint" {
  name                = format("%s%s%s", var.name, "-pe-", var.subresource_name)
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id
  tags                = local.tags

  private_service_connection {
    name                           = format("%s%s", var.name, "-psc")
    private_connection_resource_id = var.private_connection_resource_id
    is_manual_connection           = false
    subresource_names              = [var.subresource_name]
  }

/*     dynamic private_dns_zone_group {
    for_each = local.enable_private_dns_zone_group ? ["enable_private_dns_zone_group"] : []
    content {
      name = "privatelink.${each.value}.azure.com"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  } */

}

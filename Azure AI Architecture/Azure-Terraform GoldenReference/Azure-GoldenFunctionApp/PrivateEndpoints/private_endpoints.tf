locals {
  enable_private_dns_zone_group = data.azurerm_client_config.current.tenant_id != "595de295-db43-4c19-8b50-183dfd4a3d06"
}

# Create Private Endpoint
resource "azurerm_private_endpoint" "endpoint" {
  for_each            = { for pe in var.private_endpoints.endpoints : pe.subresource_name => pe }
  name                = format("%s%s%s", each.value.private_endpoint_name, "-${each.key}", "-pep")
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = each.value.private_endpoint_subnet_id
  tags                = local.tags

  private_service_connection {
    name                           = format("%s%s", each.value.private_endpoint_name, "-${each.key}")
    private_connection_resource_id = var.private_endpoints.private_connection_resource_id
    is_manual_connection           = false
    subresource_names              = [each.key]
  }

  dynamic "private_dns_zone_group" {
    for_each = local.enable_private_dns_zone_group && length(each.value.private_dns_zone_id) > 0 ? ["enable_private_dns_zone_group"] : []
    content {
      name                 = each.value.private_dns_zone_name
      private_dns_zone_ids = [each.value.private_dns_zone_id]
    }
  }

}

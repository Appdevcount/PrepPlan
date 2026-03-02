
# Create Private Endpoint
resource "azurerm_private_endpoint" "endpoint" {
  depends_on          = [azurerm_storage_account.storage_account]
  for_each            = { for pe in var.private_endpoints : pe => pe }
  name                = format("%s%s%s", var.name, "-pe-", each.value)
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.pe_subnet_id
  tags                = local.tags

  private_service_connection {
    name                           = format("%s%s", var.name, "-psc")
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    is_manual_connection           = false
    subresource_names              = [each.value]
  }

    dynamic private_dns_zone_group {
    for_each = local.enable_private_dns_zone_group ? ["enable_private_dns_zone_group"] : []
    content {
      name = "privatelink.${each.value}.azure.com"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

}
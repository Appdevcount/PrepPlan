
resource "azurerm_private_endpoint" "keyvault" {
  count = local.create_private_endpoint ? 1 : 0

  depends_on  = [azurerm_key_vault.kv]
  name                = format("%s%s", var.name, "-vault-pep")
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = local.tags

  private_service_connection {
    name                           = format("%s%s", var.name, "-vault-psc")
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
  }

  dynamic private_dns_zone_group {
    for_each = local.enable_private_dns_zone_group ? ["enable_private_dns_zone_group"] : []
    content {
      name = "privatelink.vaultcore.azure.net"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

}


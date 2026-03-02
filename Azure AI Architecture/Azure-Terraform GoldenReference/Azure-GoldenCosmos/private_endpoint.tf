resource "azurerm_private_endpoint" "cosmos" {
  count = length(var.private_endpoint_subnet_id) > 0 ? 1 : 0

  depends_on  = [azurerm_cosmosdb_account.account]
  name                = format("%s%s", var.cosmos_account_name, "-pep")
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = local.tags

  private_service_connection {
    name                           = format("%s%s", var.cosmos_account_name, "-psc")
    is_manual_connection           = false
    private_connection_resource_id = azurerm_cosmosdb_account.account.id
    subresource_names              = ["Sql"]
  }

  dynamic private_dns_zone_group {
    for_each = local.enable_private_dns_zone_group ? ["enable_private_dns_zone_group"] : []
    content {
      name = "privatelink.documents.azure.com"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

}
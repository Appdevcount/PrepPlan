resource "azurerm_private_endpoint" "endpoint" {
  depends_on          = [module.virtual_network]
  name                = format("%s%s%s", var.application, "-pe-", "blob")
  resource_group_name = var.rg_name
  location            = var.location
  subnet_id           = data.azurerm_subnet.private_endpoint_subnet.id
  tags                = var.required_tags

  private_service_connection {
    name                           = format("%s%s", module.golden_storage_account_module.storage_account_name, "-psc")
    private_connection_resource_id = module.golden_storage_account_module.storage_account_id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

}
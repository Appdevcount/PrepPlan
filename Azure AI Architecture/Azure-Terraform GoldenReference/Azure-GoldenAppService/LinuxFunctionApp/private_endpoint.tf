module "GoldenPrivateEndpoint" {
    depends_on                 = [ azurerm_linux_function_app.function ]
    count                      = local.add_private_endpoint == true ? 1 : 0
    source                     = "../PrivateEndpoints"
    name                       = var.name
    resource_group_name        = var.resource_group_name
    location                   = var.location
    required_tags              = var.required_tags
    optional_tags              = var.optional_tags
    private_endpoint_subnet_id = var.private_endpoint_subnet_id
    resource_id                = azurerm_linux_function_app.function.id
    subresource_name           = "sites"
}

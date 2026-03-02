module "GoldenPrivateEndpoint" {
    depends_on                     = [ azurerm_windows_function_app.function ]
    count                          = local.include_private_endpoint == true ? 1 : 0
    source                         = "../PrivateEndpoints"
    name                           = var.name
    resource_group_name            = var.resource_group_name
    location                       = var.location
    required_tags                  = var.required_tags
    optional_tags                  = var.optional_tags
    private_endpoint_subnet_id     = var.private_endpoint_subnet_id
    private_connection_resource_id = azurerm_windows_function_app.function.id
    subresource_name               = "sites"
}

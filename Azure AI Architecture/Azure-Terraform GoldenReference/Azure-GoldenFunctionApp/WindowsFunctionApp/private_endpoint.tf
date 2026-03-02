locals {
  include_private_endpoint          = length(var.private_endpoint_subnet_id) > 0
  include_private_endpoint_for_slot = var.include_function_app_slot && length(var.function_app_slot.private_endpoint_subnet_id) > 0
}

module "FunctionApp_PrivateEndpoint" {
    depends_on          = [ azurerm_windows_function_app.function ]
    count               = local.include_private_endpoint == true ? 1 : 0
    source              = "../PrivateEndpoints"
    resource_group_name = var.resource_group_name
    location            = var.location
    required_tags       = var.required_tags
    optional_tags       = var.optional_tags   
    private_endpoints   = { 
                            private_connection_resource_id = azurerm_windows_function_app.function.id
                            endpoints = [{
                                          private_endpoint_name      = var.name
                                          private_endpoint_subnet_id = var.private_endpoint_subnet_id
                                          private_dns_zone_name      = var.private_dns_zone_name
                                          private_dns_zone_id        = var.private_dns_zone_id
                                          subresource_name           = "sites"  
                                        }]
                          }

} 

module "FunctionAppSlot_PrivateEndpoint" {
    depends_on          = [ azurerm_windows_function_app_slot.slot ]
    count               = local.include_private_endpoint_for_slot == true ? 1 : 0
    source              = "../PrivateEndpoints"
    resource_group_name = var.resource_group_name
    location            = var.location
    required_tags       = var.required_tags
    optional_tags       = var.optional_tags   
    private_endpoints   = { 
                            private_connection_resource_id = azurerm_windows_function_app.function.id
                            endpoints = [{
                                          private_endpoint_name      = format("%s%s", var.function_app_slot.name, "-${var.name}")
                                          private_endpoint_subnet_id = var.private_endpoint_subnet_id
                                          private_dns_zone_name      = var.private_dns_zone_name
                                          private_dns_zone_id        = var.private_dns_zone_id
                                          subresource_name           = "sites-${var.function_app_slot.name}"  
                                        }]
                          }

} 


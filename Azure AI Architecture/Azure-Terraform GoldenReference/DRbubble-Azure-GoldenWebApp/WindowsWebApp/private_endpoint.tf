locals {
  include_private_endpoint          = length(var.private_endpoint_subnet_id) > 0
  include_private_endpoint_for_slot = var.include_web_app_slot && length(var.web_app_slot.private_endpoint_subnet_id) > 0
}

module "WebApp_PrivateEndpoint" {
  depends_on          = [azurerm_windows_web_app.web]
  count               = local.include_private_endpoint == true ? 1 : 0
  #source              = "../PrivateEndpoints"
  source              = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenPrivateEndpoint.git?ref=2.1.0"
  resource_group_name = var.resource_group_name
  location            = var.location
  required_tags       = var.required_tags
  optional_tags       = var.optional_tags
  nonroutable_private_endpoint = var.nonroutable_private_endpoint
  private_endpoints = [
                        { 
                           private_connection_resource_id = azurerm_windows_web_app.web.id, #Resource to add private endpoint on
                           private_endpoint_name          = var.name
                           private_endpoint_subnet_id     = var.private_endpoint_subnet_id
                           private_dns_zone_name          = var.private_dns_zone_name
                           private_dns_zone_id            = var.private_dns_zone_id
                           subresource_name               = "sites" 
                        }
                      ]

}

module "WebAppSlot_PrivateEndpoint" {
  depends_on          = [azurerm_windows_web_app_slot.slot]
  count               = local.include_private_endpoint_for_slot == true ? 1 : 0
  #source              = "../PrivateEndpoints"
  source              = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenPrivateEndpoint.git?ref=2.1.0"
  resource_group_name = var.resource_group_name
  location            = var.location
  required_tags       = var.required_tags
  optional_tags       = var.optional_tags
  nonroutable_private_endpoint = var.nonroutable_private_endpoint
  private_endpoints = [
                        { 
                           private_connection_resource_id = azurerm_windows_web_app.web.id, #Resource to add private endpoint on
                           private_endpoint_name          = var.web_app_slot.name
                           private_endpoint_subnet_id     = var.private_endpoint_subnet_id
                           private_dns_zone_name          = var.private_dns_zone_name
                           private_dns_zone_id            = var.private_dns_zone_id
                           subresource_name               = "sites-${var.web_app_slot.name}" 
                         }                      
                      ]
}
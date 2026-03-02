resource "azurerm_app_service_plan" "asp" {

  name                       = "${var.name}-asp"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  kind                       = var.kind
  reserved                   = var.kind == "Linux" ? true : false
  zone_redundant             = upper(substr(var.sku, 0, 1)) == "P" ? true : false
  app_service_environment_id = var.app_service_environment_id

  sku {
    tier = var.sku
    size = var.sku
  }

  tags = local.tags
}

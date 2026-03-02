resource "azurerm_service_plan" "asp" {

  name                         = var.name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  os_type                      = var.os_type
  sku_name                     = var.sku_name
  maximum_elastic_worker_count = var.maximum_elastic_worker_count
  worker_count                 = var.worker_count
  per_site_scaling_enabled     = var.per_site_scaling_enabled
  zone_balancing_enabled       = var.zone_balancing_enabled 
  app_service_environment_id   = var.app_service_environment_id
  tags                         = local.tags
}
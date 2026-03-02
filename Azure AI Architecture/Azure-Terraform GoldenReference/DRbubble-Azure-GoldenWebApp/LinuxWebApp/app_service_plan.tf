resource "azurerm_service_plan" "asp" {
  count                        = var.include_app_service_plan == true ? 1 : 0
  name                         = var.app_service_plan_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  os_type                      = "Linux"
  sku_name                     = var.app_service_plan_sku_name
  maximum_elastic_worker_count = var.plan_maximum_elastic_worker_count #For Elastic PLans only
  worker_count                 = var.plan_worker_count
  per_site_scaling_enabled     = var.per_site_scaling_enabled
  zone_balancing_enabled       = var.zone_balancing_enabled
  app_service_environment_id   = var.app_service_environment_id
  tags                         = local.tags
}
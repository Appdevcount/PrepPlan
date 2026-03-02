resource azurerm_application_insights function_insights {
  name = "app_insights_${var.name}"

  application_type = var.application_type
  location = var.location
  resource_group_name = var.resource_group_name
  retention_in_days = 30

  tags = local.tags
}

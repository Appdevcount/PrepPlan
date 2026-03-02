# Monitoring should be set up as an optional configuration item. Primary monitoring is provided through policy settings in Azure,
# but application teams may need additional or different monitoring for specific use cases.
data "azurerm_monitor_diagnostic_categories" "cosmos" {
  depends_on  = [azurerm_cosmosdb_account.account]
  resource_id = azurerm_cosmosdb_account.account.id
}


resource "azurerm_monitor_diagnostic_setting" "siem_diagnostics" {
  for_each   = { for setting in var.cosmosdb_diagnostics_settings : setting.name => setting }

  depends_on                     = [azurerm_cosmosdb_account.account]
  name                           = azurerm_cosmosdb_account.account.name
  target_resource_id             = azurerm_cosmosdb_account.account.id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  storage_account_id             = each.value.storage_id
  eventhub_name                  = each.value.eventhub_name
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  dynamic "metric" {
    iterator = metric_category
    for_each = data.azurerm_monitor_diagnostic_categories.cosmos.metrics

    content {
      category = metric_category.value
      enabled = each.value.include_diagnostic_metric_categories
    }
  }

  dynamic "enabled_log" {
    iterator = enabled_log_category
    for_each = data.azurerm_monitor_diagnostic_categories.cosmos.log_category_types
    content {
      category = enabled_log_category.value
    }
  }

}

resource "azurerm_monitor_metric_alert" "cosmos_ru_error" {
  count               = var.enable_default_alerting ? 1 : 0
  name                = "${local.cosmos_acct_name}-ru-alert-error"
  description         = "${var.alert_environment}|WARN|${var.location}|${local.cosmos_acct_name}-ru-alert-error|Cosmos RU Consumption Warning"
  resource_group_name = var.resource_group_name
  
  scopes = [azurerm_cosmosdb_account.account.id]
/*   action {
    action_group_id = var.monitor_action_group_id
  } */
  action {
    action_group_id    = var.alarm_funnel_id
  }

  tags = local.tags

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "NormalizedRUConsumption"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  severity = 1
}

resource "azurerm_monitor_metric_alert" "cosmos_ru_critical" {
  count               = var.enable_default_alerting ? 1 : 0
  name                = "${local.cosmos_acct_name}-ru-alert-critical"
  description         = "${var.alert_environment}|CRITICAL|${var.location}|${local.cosmos_acct_name}-ru-alert-critical|Cosmos RU Consumption Critical"
  resource_group_name = var.resource_group_name
  
  scopes = [azurerm_cosmosdb_account.account.id]
/*   action {
    action_group_id = var.monitor_action_group_id
  } */
  action {
    action_group_id    = var.alarm_funnel_id
  }

  tags = local.tags

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "NormalizedRUConsumption"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 99
  }

  severity = 0
}

resource "azurerm_monitor_metric_alert" "cosmos_availability" {
  count               = var.enable_default_alerting ? 1 : 0
  name                = "${local.cosmos_acct_name}-ru-alert-availability"
  description         = "${var.alert_environment}|CRITICAL|${var.location}|${local.cosmos_acct_name}-ru-alert-availability|Cosmos Service Availability"
  resource_group_name = var.resource_group_name
  
  scopes = [azurerm_cosmosdb_account.account.id]
  action {
    action_group_id    = var.alarm_funnel_id
  }

  tags = local.tags

  window_size = "PT1H"
  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "ServiceAvailability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100
  }

  severity = 0
}
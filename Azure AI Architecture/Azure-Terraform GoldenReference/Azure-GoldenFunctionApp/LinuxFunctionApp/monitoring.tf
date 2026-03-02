data "azurerm_monitor_diagnostic_categories" "function" {
  depends_on  = [azurerm_linux_function_app.function]
  resource_id = azurerm_linux_function_app.function.id
}
data "azurerm_monitor_diagnostic_categories" "function_slot" {
  depends_on  = [azurerm_linux_function_app_slot.slot]
  count       = var.include_function_app_slot == true ? 1 : 0
  resource_id = azurerm_linux_function_app_slot.slot.0.id
}

resource "azurerm_monitor_action_group" "alert_ag" {
  count               = var.include_alerts ? 1 : 0
  name                = "${var.name}-func-alert-ag"
  resource_group_name = var.resource_group_name
  short_name          = "FuncAlerts"
  email_receiver {
    name          = "Alert-ActionGroup"
    email_address = var.alert_action_group_email
    use_common_alert_schema = true
  }
  tags             = var.required_tags
}

resource "azurerm_log_analytics_workspace" "workspace" {
  count                      = var.include_app_insights  ? 1 : 0  
  name                       = "${var.app_service_plan_name}-law"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  internet_query_enabled     = true
  internet_ingestion_enabled = true
  tags                       = var.required_tags
}

resource "azurerm_application_insights" "appinsights" {
  depends_on                          = [azurerm_log_analytics_workspace.workspace]  
  count                               = var.include_app_insights ? 1 : 0     
  name                                = "${var.app_service_plan_name}-ai"
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  workspace_id                        = azurerm_log_analytics_workspace.workspace.0.id
  application_type                    = "web"
  internet_ingestion_enabled          = true
  internet_query_enabled              = true
  local_authentication_disabled       = false
  force_customer_storage_for_profiler = false
  sampling_percentage                 = 0
  tags                                = var.required_tags
}


resource azurerm_monitor_diagnostic_setting function {
  for_each                       = { for setting in var.function_diagnostics_settings : setting.name => setting }
  depends_on                     = [azurerm_linux_function_app.function]

  name                           = each.key
  target_resource_id             = azurerm_linux_function_app.function.id
  storage_account_id             = each.value.storage_account_id == "" ? null : each.value.storage_account_id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id == "" ? null : each.value.log_analytics_workspace_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id == "" ? null : each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name == "" ? null : each.value.eventhub_name
 
  dynamic "enabled_log" {
    iterator = enabled_log_category
    for_each = data.azurerm_monitor_diagnostic_categories.function.log_category_types

    content {
      category = enabled_log_category.value
    }
  }

  dynamic "metric" {
    iterator = metric_name
    for_each = data.azurerm_monitor_diagnostic_categories.function.metrics

    content {
      category = metric_name.value
      enabled = each.value.include_diagnostic_metric_categories 
    }
  }
}

resource azurerm_monitor_diagnostic_setting function_slot {
  for_each                       = var.include_function_app_slot ? { for setting in var.function_diagnostics_settings : setting.name => setting } : {}
  depends_on                     = [azurerm_linux_function_app_slot.slot]

  name                           = each.key
  target_resource_id             = azurerm_linux_function_app_slot.slot.0.id
  storage_account_id             = each.value.storage_account_id == "" ? null : each.value.storage_account_id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id == "" ? null : each.value.log_analytics_workspace_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id == "" ? null : each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name == "" ? null : each.value.eventhub_name
 
  dynamic "enabled_log" {
    iterator = enabled_log_category
    for_each = data.azurerm_monitor_diagnostic_categories.function_slot.0.log_category_types

    content {
      category = enabled_log_category.value
    }
  }

  dynamic "metric" {
    iterator = metric_name
    for_each = data.azurerm_monitor_diagnostic_categories.function_slot.0.metrics

    content {
      category = metric_name.value
      enabled = each.value.include_diagnostic_metric_categories 
    }
  }
}

resource "azurerm_monitor_activity_log_alert" "functionstopped" {
  depends_on          = [azurerm_linux_function_app.function, azurerm_monitor_action_group.alert_ag]
  count               = var.include_alerts ? 1 : 0
  name                = "${var.name}-Function-Stopped-Alert"
  description         = "${upper(var.environment)}|CRITICAL|${var.location}|${var.name}-Stopped-Alert|Function app is stopped"
  resource_group_name = var.resource_group_name
  scopes = [
    azurerm_linux_function_app.function.id
  ]
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Web/sites/stop/Action"
  }
   action {
     action_group_id = data.azurerm_monitor_action_group.alarm_funnel.0.id
     webhook_properties = {}
  }
   action {
     action_group_id    = azurerm_monitor_action_group.alert_ag.0.id
     webhook_properties = {}
   }
  tags                  = var.required_tags
} 

resource "azurerm_monitor_metric_alert" "httpservererrors" {
  depends_on          = [azurerm_linux_function_app.function, azurerm_monitor_action_group.alert_ag]
  count               = var.include_alerts ? 1 : 0
  name                = "${var.name}-http-server-errors"
  resource_group_name = var.resource_group_name
  scopes = [ azurerm_linux_function_app.function.id ]
  description         = "${upper(var.environment)}|WARN|${var.location}|${var.name}-http-server-errors|Excessive server errors detected"

  dynamic_criteria {
    metric_namespace  = "Microsoft.Web/sites"
    metric_name       = "HTTP5xx"
    aggregation       = "Total"
    operator          = "GreaterThan"
    alert_sensitivity = "Medium"
  }

  action {
     action_group_id = data.azurerm_monitor_action_group.alarm_funnel.0.id
     webhook_properties = {}
  }
  action {
     action_group_id    = azurerm_monitor_action_group.alert_ag.0.id
     webhook_properties = {}
   }

  tags = var.required_tags
}

resource "azurerm_monitor_metric_alert" "healthcheck" {
  depends_on          = [azurerm_linux_function_app.function, azurerm_monitor_action_group.alert_ag]
  count               = var.include_alerts ? 1 : 0
  name                = "${var.name}-function-health-check"
  resource_group_name = var.resource_group_name
  scopes              = [ azurerm_linux_function_app.function.id ]
  description         = "${upper(var.environment)}|INFO|${var.location}|${var.name}-function-health-check|Function Health Check"

  frequency = "PT1M"
  criteria {
    aggregation      = "Average"
    metric_name      = "HealthCheckStatus"
    metric_namespace = "Microsoft.Web/sites"
    operator         = "LessThan"
    threshold        = "100"
  }

  action {
     action_group_id = data.azurerm_monitor_action_group.alarm_funnel.0.id
     webhook_properties = {}
  }
  action {
     action_group_id    = azurerm_monitor_action_group.alert_ag.0.id
     webhook_properties = {}
   }

  tags = var.required_tags
}


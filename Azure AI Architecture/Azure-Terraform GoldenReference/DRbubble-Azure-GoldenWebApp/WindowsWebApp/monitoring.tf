data "azurerm_monitor_diagnostic_categories" "web" {
  depends_on  = [azurerm_windows_web_app.web]
  resource_id = azurerm_windows_web_app.web.id
}
data "azurerm_monitor_diagnostic_categories" "web_slot" {
  depends_on  = [azurerm_windows_web_app_slot.slot]
  count       = var.include_web_app_slot == true ? 1 : 0
  resource_id = azurerm_windows_web_app_slot.slot.0.id
}

locals {
  alarm_funnel_app_name = var.alarm_funnel_app_name == null || var.alarm_funnel_app_name == "" ? var.name : var.alarm_funnel_app_name
}


resource "azurerm_monitor_action_group" "alert_ag" {
  count               = var.include_alerts && var.include_alert_action_group ? 1 : 0
  name                = "${var.name}-alert-notification-ag"
  resource_group_name = var.resource_group_name
  short_name          = "Email Alerts"
  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name                    = "EmailAlert${email_receiver.key}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }

  }
  tags = local.tags
}


resource "azurerm_log_analytics_workspace" "workspace" {
  count                      = var.include_app_insights ? 1 : 0
  name                       = "${var.name}-law"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  internet_query_enabled     = true
  internet_ingestion_enabled = true
  tags                       = local.tags
}

resource "azurerm_application_insights" "appinsights" {
  depends_on                          = [azurerm_log_analytics_workspace.workspace]
  count                               = var.include_app_insights ? 1 : 0
  name                                = "${var.name}-ai"
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  workspace_id                        = azurerm_log_analytics_workspace.workspace.0.id
  application_type                    = "web"
  internet_ingestion_enabled          = true
  internet_query_enabled              = true
  local_authentication_disabled       = false
  force_customer_storage_for_profiler = false
  sampling_percentage                 = 0
  tags                                = local.tags

  lifecycle {

    precondition {
      condition     = var.include_app_insights ? !contains(keys(var.app_settings), "APPINSIGHTS_INSTRUMENTATIONKEY") && !contains(keys(var.app_settings), "APPLICATIONINSIGHTS_CONNECTION_STRING") && !contains(keys(var.app_settings), "ApplicationInsightsAgent_EXTENSION_VERSION") : true
      error_message = "When setting 'include_app_insights' = true, do not include the following app settings: APPINSIGHTS_INSTRUMENTATIONKEY, APPLICATIONINSIGHTS_CONNECTION_STRING, ApplicationInsightsAgent_EXTENSION_VERSION. The golden module will add these settings with the appropriate value."
    }
  }
}


resource "azurerm_monitor_diagnostic_setting" "webapp" {
  for_each   = { for setting in var.webapp_diagnostics_settings : setting.name => setting }
  depends_on = [azurerm_windows_web_app.web]

  name                           = each.key
  target_resource_id             = azurerm_windows_web_app.web.id
  storage_account_id             = each.value.storage_account_id == "" ? null : each.value.storage_account_id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id == "" ? null : each.value.log_analytics_workspace_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id == "" ? null : each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name == "" ? null : each.value.eventhub_name

  dynamic "enabled_log" {
    iterator = enabled_log_category
    for_each = data.azurerm_monitor_diagnostic_categories.web.log_category_types

    content {
      category = enabled_log_category.value
    }
  }

  dynamic "enabled_metric" {
    iterator = metric_name
    for_each = data.azurerm_monitor_diagnostic_categories.web.metrics

    content {
      category = metric_name.value
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "web_slot" {
  for_each   = var.include_web_app_slot ? { for setting in var.webapp_diagnostics_settings : setting.name => setting } : {}
  depends_on = [azurerm_windows_web_app_slot.slot]

  name                           = each.key
  target_resource_id             = azurerm_windows_web_app_slot.slot.0.id
  storage_account_id             = each.value.storage_account_id == "" ? null : each.value.storage_account_id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id == "" ? null : each.value.log_analytics_workspace_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id == "" ? null : each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name == "" ? null : each.value.eventhub_name

  dynamic "enabled_log" {
    iterator = enabled_log_category
    for_each = data.azurerm_monitor_diagnostic_categories.web_slot.0.log_category_types

    content {
      category = enabled_log_category.value
    }
  }

  dynamic "enabled_metric" {
    iterator = metric_name
    for_each = data.azurerm_monitor_diagnostic_categories.web_slot.0.metrics

    content {
      category = metric_name.value
    }
  }
}



resource "azurerm_monitor_activity_log_alert" "webappstopped" {
  depends_on          = [azurerm_windows_web_app.web, azurerm_monitor_action_group.alert_ag]
  count               = var.include_alerts && var.alerts.webapp_stopped.include ? 1 : 0
  name                = "${var.name}-webapp-stopped-alert"
  resource_group_name = var.resource_group_name
  location            = "Global"
  scopes              = [azurerm_windows_web_app.web.id]
  description         = "${upper(var.alarm_funnel_environment)}|${upper(var.alerts.webapp_stopped.alarm_funnel_severity)}|${var.location}|${local.alarm_funnel_app_name}|Webapp Stopped Alert"
  tags                = local.tags

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Web/sites/stop/Action"
  }

  dynamic "action" {
    for_each = local.add_action_group ? ["add_action_group"] : []
    content {
      action_group_id = local.use_external_action_group ? var.external_action_group_id : azurerm_monitor_action_group.alert_ag.0.id
    }
  }
  action {
    action_group_id = local.alarm_funnel.action_group_id
  }
}

resource "azurerm_monitor_metric_alert" "http_server_errors" {
  depends_on          = [azurerm_windows_web_app.web]
  count               = var.include_alerts && var.alerts.http_server_errors.include ? 1 : 0
  name                = "${var.name}-http-server-errors-alert"
  resource_group_name = var.resource_group_name
  description         = "${upper(var.alarm_funnel_environment)}|${upper(var.alerts.http_server_errors.alarm_funnel_severity)}|${var.location}|${local.alarm_funnel_app_name}|Web App Http Server Errors Alert"
  severity            = var.alerts.http_server_errors.alert_severity
  scopes              = [azurerm_windows_web_app.web.id]
  frequency           = var.alerts.http_server_errors.frequency
  window_size         = var.alerts.http_server_errors.window_size
  auto_mitigate       = var.alerts.http_server_errors.auto_mitigate
  tags                = local.tags

  dynamic "criteria" {
    for_each = var.alerts.http_server_errors.use_dynamic_criteria == false ? ["use_criteria"] : []
    content {
      metric_namespace = "Microsoft.Web/sites"
      metric_name      = "HTTP5xx"
      aggregation      = var.alerts.http_server_errors.aggregation
      operator         = var.alerts.http_server_errors.operator
      threshold        = var.alerts.http_server_errors.threshold

    }

  }

  dynamic "dynamic_criteria" {
    for_each = var.alerts.http_server_errors.use_dynamic_criteria ? ["use_dynamic_criteria"] : []
    content {
      metric_namespace         = "Microsoft.Web/sites"
      metric_name              = "HTTP5xx"
      aggregation              = var.alerts.http_server_errors.aggregation
      operator                 = var.alerts.http_server_errors.operator
      alert_sensitivity        = var.alerts.http_server_errors.alert_sensitivity
      evaluation_total_count   = var.alerts.http_server_errors.evaluation_total_count
      evaluation_failure_count = var.alerts.http_server_errors.evaluation_failure_count

    }
  }

  dynamic "action" {
    for_each = local.add_action_group ? ["add_action_group"] : []
    content {
      action_group_id = local.use_external_action_group ? var.external_action_group_id : azurerm_monitor_action_group.alert_ag.0.id
      webhook_properties = {}
    }
  }
  action {
    action_group_id = local.alarm_funnel.action_group_id
  }

}

resource "azurerm_monitor_metric_alert" "health_check" {
  depends_on          = [azurerm_windows_web_app.web]
  count               = var.include_alerts && var.alerts.health_check.include ? 1 : 0
  name                = "${var.name}-health-check-alert"
  resource_group_name = var.resource_group_name
  description         = "${upper(var.alarm_funnel_environment)}|${upper(var.alerts.health_check.alarm_funnel_severity)}|${var.location}|${local.alarm_funnel_app_name}|Web App Health Check Alert"
  severity            = var.alerts.health_check.alert_severity
  scopes              = [azurerm_windows_web_app.web.id]
  frequency           = var.alerts.health_check.frequency
  window_size         = var.alerts.health_check.window_size
  auto_mitigate       = var.alerts.health_check.auto_mitigate
  tags                = local.tags

  dynamic "criteria" {
    for_each = var.alerts.health_check.use_dynamic_criteria == false ? ["use_criteria"] : []
    content {
      metric_namespace = "Microsoft.Web/sites"
      metric_name      = "HealthCheckStatus"
      aggregation      = var.alerts.health_check.aggregation
      operator         = var.alerts.health_check.operator
      threshold        = var.alerts.health_check.threshold

    }

  }

  dynamic "dynamic_criteria" {
    for_each = var.alerts.health_check.use_dynamic_criteria ? ["use_dynamic_criteria"] : []
    content {
      metric_namespace         = "Microsoft.Web/sites"
      metric_name              = "HealthCheckStatus"
      aggregation              = var.alerts.health_check.aggregation
      operator                 = var.alerts.health_check.operator
      alert_sensitivity        = var.alerts.health_check.alert_sensitivity
      evaluation_total_count   = var.alerts.health_check.evaluation_total_count
      evaluation_failure_count = var.alerts.health_check.evaluation_failure_count

    }
  }

  dynamic "action" {
    for_each = local.add_action_group ? ["add_action_group"] : []
    content {
      action_group_id = local.use_external_action_group ? var.external_action_group_id : azurerm_monitor_action_group.alert_ag.0.id
      webhook_properties = {}
    }
  }
  action {
    action_group_id = local.alarm_funnel.action_group_id
  }

}

resource "azurerm_monitor_metric_alert" "cpu_percentage" {
  depends_on          = [azurerm_windows_web_app.web]
  count               = var.include_alerts && var.alerts.cpu_percentage.include ? 1 : 0
  name                = "${var.name}-cpu-percentage-alert"
  resource_group_name = var.resource_group_name
  description         = "${upper(var.alarm_funnel_environment)}|${upper(var.alerts.cpu_percentage.alarm_funnel_severity)}|${var.location}|${local.alarm_funnel_app_name}|Web App CPU Percentage Alert"
  severity            = var.alerts.cpu_percentage.alert_severity
  scopes              = var.include_app_service_plan ? [azurerm_service_plan.asp.0.id] : [var.service_plan_id]
  frequency           = var.alerts.cpu_percentage.frequency
  window_size         = var.alerts.cpu_percentage.window_size
  auto_mitigate       = var.alerts.cpu_percentage.auto_mitigate
  tags                = local.tags

  dynamic "criteria" {
    for_each = var.alerts.cpu_percentage.use_dynamic_criteria == false ? ["use_criteria"] : []
    content {
      metric_namespace = "Microsoft.Web/serverfarms"
      metric_name      = "CpuPercentage"
      aggregation      = var.alerts.cpu_percentage.aggregation
      operator         = var.alerts.cpu_percentage.operator
      threshold        = var.alerts.cpu_percentage.threshold

    }

  }

  dynamic "dynamic_criteria" {
    for_each = var.alerts.cpu_percentage.use_dynamic_criteria ? ["use_dynamic_criteria"] : []
    content {
      metric_namespace         = "Microsoft.Web/serverfarms"
      metric_name              = "CpuPercentage"
      aggregation              = var.alerts.cpu_percentage.aggregation
      operator                 = var.alerts.cpu_percentage.operator
      alert_sensitivity        = var.alerts.cpu_percentage.alert_sensitivity
      evaluation_total_count   = var.alerts.cpu_percentage.evaluation_total_count
      evaluation_failure_count = var.alerts.cpu_percentage.evaluation_failure_count

    }
  }

  dynamic "action" {
    for_each = local.add_action_group ? ["add_action_group"] : []
    content {
      action_group_id = local.use_external_action_group ? var.external_action_group_id : azurerm_monitor_action_group.alert_ag.0.id
      webhook_properties = {}
    }
  }
  action {
    action_group_id = local.alarm_funnel.action_group_id
  }

}

resource "azurerm_monitor_metric_alert" "memory_percentage" {
  depends_on          = [azurerm_windows_web_app.web]
  count               = var.include_alerts && var.alerts.memory_percentage.include ? 1 : 0
  name                = "${var.name}-memory-percentage-alert"
  resource_group_name = var.resource_group_name
  description         = "${upper(var.alarm_funnel_environment)}|${upper(var.alerts.memory_percentage.alarm_funnel_severity)}|${var.location}|${local.alarm_funnel_app_name}|Web App Memory Percentage Alert"
  severity            = var.alerts.memory_percentage.alert_severity
  scopes              = var.include_app_service_plan ? [azurerm_service_plan.asp.0.id] : [var.service_plan_id]
  frequency           = var.alerts.memory_percentage.frequency
  window_size         = var.alerts.memory_percentage.window_size
  auto_mitigate       = var.alerts.memory_percentage.auto_mitigate
  tags                = local.tags

  dynamic "criteria" {
    for_each = var.alerts.memory_percentage.use_dynamic_criteria == false ? ["use_criteria"] : []
    content {
      metric_namespace = "Microsoft.Web/serverfarms"
      metric_name      = "MemoryPercentage"
      aggregation      = var.alerts.memory_percentage.aggregation
      operator         = var.alerts.memory_percentage.operator
      threshold        = var.alerts.memory_percentage.threshold

    }

  }

  dynamic "dynamic_criteria" {
    for_each = var.alerts.memory_percentage.use_dynamic_criteria ? ["use_dynamic_criteria"] : []
    content {
      metric_namespace         = "Microsoft.Web/serverfarms"
      metric_name              = "MemoryPercentage"
      aggregation              = var.alerts.memory_percentage.aggregation
      operator                 = var.alerts.memory_percentage.operator
      alert_sensitivity        = var.alerts.memory_percentage.alert_sensitivity
      evaluation_total_count   = var.alerts.memory_percentage.evaluation_total_count
      evaluation_failure_count = var.alerts.memory_percentage.evaluation_failure_count

    }
  }

  dynamic "action" {
    for_each = local.add_action_group ? ["add_action_group"] : []
    content {
      action_group_id = local.use_external_action_group ? var.external_action_group_id : azurerm_monitor_action_group.alert_ag.0.id
      webhook_properties = {}
    }
  }
  action {
    action_group_id = local.alarm_funnel.action_group_id
  }

}

resource "azurerm_monitor_metric_alert" "http_queue_length" {
  depends_on          = [azurerm_windows_web_app.web]
  count               = var.include_alerts && var.alerts.http_queue_length.include ? 1 : 0
  name                = "${var.name}-http-queue-length-alert"
  resource_group_name = var.resource_group_name
  description         = "${upper(var.alarm_funnel_environment)}|${upper(var.alerts.http_queue_length.alarm_funnel_severity)}|${var.location}|${local.alarm_funnel_app_name}|Web App Http Queue Length Alert"
  severity            = var.alerts.http_queue_length.alert_severity
  scopes              = var.include_app_service_plan ? [azurerm_service_plan.asp.0.id] : [var.service_plan_id]
  frequency           = var.alerts.http_queue_length.frequency
  window_size         = var.alerts.http_queue_length.window_size
  auto_mitigate       = var.alerts.http_queue_length.auto_mitigate
  tags                = local.tags

  dynamic "criteria" {
    for_each = var.alerts.http_queue_length.use_dynamic_criteria == false ? ["use_criteria"] : []
    content {
      metric_namespace = "Microsoft.Web/serverfarms"
      metric_name      = "HttpQueueLength"
      aggregation      = var.alerts.http_queue_length.aggregation
      operator         = var.alerts.http_queue_length.operator
      threshold        = var.alerts.http_queue_length.threshold

    }

  }

  dynamic "dynamic_criteria" {
    for_each = var.alerts.http_queue_length.use_dynamic_criteria ? ["use_dynamic_criteria"] : []
    content {
      metric_namespace         = "Microsoft.Web/serverfarms"
      metric_name              = "HttpQueueLength"
      aggregation              = var.alerts.http_queue_length.aggregation
      operator                 = var.alerts.http_queue_length.operator
      alert_sensitivity        = var.alerts.http_queue_length.alert_sensitivity
      evaluation_total_count   = var.alerts.http_queue_length.evaluation_total_count
      evaluation_failure_count = var.alerts.http_queue_length.evaluation_failure_count

    }
  }

  dynamic "action" {
    for_each = local.add_action_group ? ["add_action_group"] : []
    content {
      action_group_id = local.use_external_action_group ? var.external_action_group_id : azurerm_monitor_action_group.alert_ag.0.id
      webhook_properties = {}
    }
  }
  action {
    action_group_id = local.alarm_funnel.action_group_id
  }

}



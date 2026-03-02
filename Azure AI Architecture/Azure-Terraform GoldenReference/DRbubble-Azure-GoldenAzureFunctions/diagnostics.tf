resource azurerm_monitor_diagnostic_setting function_diagnostics {
  count = var.monitor_log_storage_account_id == null ? 0 : 1

  name               = var.name
  target_resource_id = azurerm_function_app.function.id
  storage_account_id = var.monitor_log_storage_account_id

  dynamic "log" {
    iterator = log_category
    for_each = data.azurerm_monitor_diagnostic_categories.function_diagnostic_catagories[0].logs

    content {
      category = log_category.value
      enabled  = true

      retention_policy {
        enabled = true
        days    = 91
      }
    }
  }

  dynamic "metric" {
    iterator = metric_category
    for_each = data.azurerm_monitor_diagnostic_categories.function_diagnostic_catagories[0].metrics

    content {
      category = metric_category.value
      enabled  = true

      retention_policy {
        enabled = true
        days    = 91
      }
    }
  }
}

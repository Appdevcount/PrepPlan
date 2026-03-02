data "azurerm_monitor_diagnostic_categories" "storage" {
  depends_on  = [azurerm_storage_account.storage_account]
  resource_id = azurerm_storage_account.storage_account.id
}
data "azurerm_monitor_diagnostic_categories" "storage_blob" {
  depends_on  = [azurerm_storage_account.storage_account]
  resource_id = "${azurerm_storage_account.storage_account.id}/blobServices/default/"
}

data "azurerm_monitor_diagnostic_categories" "storage_file" {
  depends_on  = [azurerm_storage_account.storage_account]
  resource_id = "${azurerm_storage_account.storage_account.id}/fileServices/default/"
}

data "azurerm_monitor_diagnostic_categories" "storage_queue" {
  depends_on  = [azurerm_storage_account.storage_account]
  resource_id = "${azurerm_storage_account.storage_account.id}/queueServices/default/"
}

data "azurerm_monitor_diagnostic_categories" "storage_table" {
  depends_on  = [azurerm_storage_account.storage_account]
  resource_id = "${azurerm_storage_account.storage_account.id}/tableServices/default/"
}

resource azurerm_monitor_diagnostic_setting storage_diagnostics {
  for_each   = { for setting in var.storage_diagnostics_settings : setting.name => setting }
  depends_on = [azurerm_storage_account.storage_account]

  name                           = each.key
  target_resource_id             = azurerm_storage_account.storage_account.id
  storage_account_id             = each.value.storage_account_id == "" ? null : each.value.storage_account_id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id == "" ? null : each.value.log_analytics_workspace_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id == "" ? null : each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name == "" ? null : each.value.eventhub_name
 
  dynamic "enabled_log" {
    iterator = enabled_log_category
    for_each = data.azurerm_monitor_diagnostic_categories.storage.log_category_types

    content {
      category = enabled_log_category.value
    }
  }

  dynamic "metric" {
    iterator = metric_name
    for_each = data.azurerm_monitor_diagnostic_categories.storage.metrics

    content {
      category = metric_name.value
      enabled = each.value.include_diagnostic_metric_categories 
    }
  }
}
resource azurerm_monitor_diagnostic_setting storage_blob_diagnostics {
  for_each   = { for setting in var.blob_diagnostics_settings : setting.name => setting }
  depends_on = [azurerm_storage_account.storage_account]

  name                           = each.key
  target_resource_id             = data.azurerm_monitor_diagnostic_categories.storage_blob.resource_id
  storage_account_id             = each.value.storage_account_id == "" ? null : each.value.storage_account_id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id == "" ? null : each.value.log_analytics_workspace_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id == "" ? null : each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name == "" ? null : each.value.eventhub_name
 
  dynamic "enabled_log" {
    iterator = enabled_log_category
    for_each = data.azurerm_monitor_diagnostic_categories.storage_blob.log_category_types

    content {
      category = enabled_log_category.value
    }
  }

  dynamic "metric" {
    iterator = metric_name
    for_each = data.azurerm_monitor_diagnostic_categories.storage_blob.metrics

    content {
      category = metric_name.value
      enabled = each.value.include_diagnostic_metric_categories 
    }
  }
}
resource azurerm_monitor_diagnostic_setting storage_file_diagnostics {
  for_each   = { for setting in var.file_diagnostics_settings : setting.name => setting }
  depends_on = [azurerm_storage_account.storage_account]

  name                           = each.key
  target_resource_id             = data.azurerm_monitor_diagnostic_categories.storage_file.resource_id
  storage_account_id             = each.value.storage_account_id == "" ? null : each.value.storage_account_id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id == "" ? null : each.value.log_analytics_workspace_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id == "" ? null : each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name == "" ? null : each.value.eventhub_name
 
  dynamic "enabled_log" {
    iterator = enabled_log_category
    for_each = data.azurerm_monitor_diagnostic_categories.storage_file.log_category_types

    content {
      category = enabled_log_category.value
    }
  }

  dynamic "metric" {
    iterator = metric_name
    for_each = data.azurerm_monitor_diagnostic_categories.storage_file.metrics

    content {
      category = metric_name.value
      enabled = each.value.include_diagnostic_metric_categories 
    }
  }
}

resource azurerm_monitor_diagnostic_setting storage_queue_diagnostics {
  for_each = { for setting in var.queue_diagnostics_settings : setting.name => setting }
  depends_on = [azurerm_storage_account.storage_account]

  name                           = each.key
  target_resource_id             = data.azurerm_monitor_diagnostic_categories.storage_queue.resource_id
  storage_account_id             = each.value.storage_account_id == "" ? null : each.value.storage_account_id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id == "" ? null : each.value.log_analytics_workspace_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id == "" ? null : each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name == "" ? null : each.value.eventhub_name
 
  dynamic "enabled_log" {
    iterator = enabled_log_category
    for_each = data.azurerm_monitor_diagnostic_categories.storage_queue.log_category_types

    content {
      category = enabled_log_category.value
    }
  }

  dynamic "metric" {
    iterator = metric_name
    for_each = data.azurerm_monitor_diagnostic_categories.storage_queue.metrics

    content {
      category = metric_name.value
      enabled = each.value.include_diagnostic_metric_categories
    }
  }
}
resource azurerm_monitor_diagnostic_setting storage_table_diagnostics {
  for_each = { for setting in var.table_diagnostics_settings : setting.name => setting }
  depends_on = [azurerm_storage_account.storage_account]

  name                           = each.key
  target_resource_id             = data.azurerm_monitor_diagnostic_categories.storage_table.resource_id
  storage_account_id             = each.value.storage_account_id == "" ? null : each.value.storage_account_id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id == "" ? null : each.value.log_analytics_workspace_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id == "" ? null : each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name == "" ? null : each.value.eventhub_name
 
  dynamic "enabled_log" {
    iterator = enabled_log_category
    for_each = data.azurerm_monitor_diagnostic_categories.storage_table.log_category_types

    content {
      category = enabled_log_category.value
    }
  }

  dynamic "metric" {
    iterator = metric_name
    for_each = data.azurerm_monitor_diagnostic_categories.storage_table.metrics

    content {
      category = metric_name.value
      enabled = each.value.include_diagnostic_metric_categories 
    }
  }
}

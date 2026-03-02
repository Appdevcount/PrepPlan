data "azurerm_monitor_diagnostic_categories" "keyvault" {
  depends_on  = [azurerm_key_vault.kv]
  resource_id = azurerm_key_vault.kv.id
}

resource "azurerm_monitor_diagnostic_setting" "siem_diagnostics" {
  for_each   = { for setting in var.keyvault_diagnostics_settings : setting.name => setting }

  depends_on  = [azurerm_key_vault.kv]
  name                           = each.key
  target_resource_id             = azurerm_key_vault.kv.id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id == "" ? null : each.value.log_analytics_workspace_id
  storage_account_id             = each.value.storage_id == "" ? null : each.value.storage_id
  eventhub_name                  = each.value.eventhub_name == "" ? null : each.value.eventhub_name
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id == "" ? null : each.value.eventhub_authorization_rule_id

  dynamic "metric" {
    iterator = metric_category
    for_each = data.azurerm_monitor_diagnostic_categories.keyvault.metrics

    content {
      category = metric_category.value
      enabled = each.value.include_diagnostic_metric_categories
    }
  }

  dynamic "enabled_log" {
    iterator = enabled_log_category
    for_each = each.value.include_diagnostic_log_categories ? data.azurerm_monitor_diagnostic_categories.keyvault.log_category_types : []

    content {
      category = enabled_log_category.value
    }
  }

}

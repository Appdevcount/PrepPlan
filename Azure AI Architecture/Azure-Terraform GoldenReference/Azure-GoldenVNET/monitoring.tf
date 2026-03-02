locals {
  network_log_types    = ["VMProtectionAlerts"]
  network_metric_types = ["AllMetrics"]

  nsg_log_types = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]
}

resource "azurerm_monitor_diagnostic_setting" "network_diagnostics" {
  count = var.enable_diagnostics && length(var.subnets) > 0 ? 1 : 0
  depends_on         = [azurerm_virtual_network.goldenVNET]
  name               = azurerm_virtual_network.goldenVNET[0].name
  target_resource_id = azurerm_virtual_network.goldenVNET[0].id
  storage_account_id = var.monitor_log_storage_account_id

  dynamic "enabled_log" {
    iterator = enabled_category
    for_each = toset(local.network_log_types)

    content {
      category = enabled_category.value
    }
  }

  dynamic "metric" {
    iterator = metric_category
    for_each = toset(local.network_metric_types)

    content {
      category = metric_category.value
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "network_diagnostics_nonroutable" {
  count = var.enable_diagnostics && length(var.nonRoutableSubnets) > 0  ? 1 : 0
  depends_on         = [azurerm_virtual_network.goldenVNET_nonroutable]
  name               = azurerm_virtual_network.goldenVNET_nonroutable[0].name
  target_resource_id = azurerm_virtual_network.goldenVNET_nonroutable[0].id
  storage_account_id = var.monitor_log_storage_account_id

  dynamic "enabled_log" {
    iterator = enabled_category
    for_each = toset(local.network_log_types)

    content {
      category = enabled_category.value
    }
  }

  dynamic "metric" {
    iterator = metric_category
    for_each = toset(local.network_metric_types)

    content {
      category = metric_category.value
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg_diagnostics" {
  count = var.enable_diagnostics && length(var.subnets) > 0 ? 1 : 0

  name               = azurerm_network_security_group.default[0].name
  target_resource_id = azurerm_network_security_group.default[0].id
  storage_account_id = var.monitor_log_storage_account_id

  dynamic "enabled_log" {
    iterator = enabled_category
    for_each = toset(local.nsg_log_types)

    content {
      category = enabled_category.value
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "nonroutable_nsg_diagnostics" {
  count = var.enable_diagnostics && length(var.nonRoutableSubnets) > 0 ? 1 : 0

  name               = azurerm_network_security_group.default-nonroutable[0].name
  target_resource_id = azurerm_network_security_group.default-nonroutable[0].id
  storage_account_id = var.monitor_log_storage_account_id

  dynamic "enabled_log" {
    iterator = enabled_category
    for_each = toset(local.nsg_log_types)

    content {
      category = enabled_category.value
    }
  }
}

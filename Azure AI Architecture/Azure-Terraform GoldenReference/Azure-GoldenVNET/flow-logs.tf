resource "azurerm_network_watcher_flow_log" "routable_flow_logs" {
  count = length(var.subnets) > 0 ? 1 : 0
  depends_on          = [azurerm_virtual_network.goldenVNET]
  name                = format("%s%s", var.application, var.flow_log_suffix_name)
  
  network_watcher_name = "NetworkWatcher_${lower(azurerm_virtual_network.goldenVNET[0].location)}"
  resource_group_name  = "NetworkWatcherRG"
  location = azurerm_virtual_network.goldenVNET[0].location

  network_security_group_id = azurerm_network_security_group.default[0].id
  storage_account_id        = var.flow_storage_id
  enabled                   = true

  version = 2

  retention_policy {
    enabled = true
    days    = 91
  }

  tags = local.tags

}

resource "azurerm_network_watcher_flow_log" "nonroutable_flow_logs" {
  count = length(var.nonRoutableSubnets) > 0 ? 1 : 0
  depends_on          = [azurerm_virtual_network.goldenVNET_nonroutable]
  name                = format("%s%s", var.application, var.nonroutable_flow_log_suffix_name)
  
  network_watcher_name = "NetworkWatcher_${lower(azurerm_virtual_network.goldenVNET_nonroutable[0].location)}"
  resource_group_name  = "NetworkWatcherRG"
  location = azurerm_virtual_network.goldenVNET_nonroutable[0].location

  network_security_group_id = azurerm_network_security_group.default-nonroutable[0].id
  storage_account_id = var.flow_storage_id
  enabled                   = true

  version = 2

  retention_policy {
    enabled = true
    days    = 91
  }

  tags = local.tags

}
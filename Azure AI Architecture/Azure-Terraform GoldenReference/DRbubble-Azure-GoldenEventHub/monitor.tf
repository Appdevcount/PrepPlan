locals {
  destination = join("", [
    var.log_analytics_workspace_id != null ? "_LAW" : "",
    var.log_storage_account_id != null ? "_storage" : "",
    var.log_eventhub_namespace_authorization_rule_id != null ? "_Event-Hub" : ""
    ])
}

resource "azurerm_monitor_diagnostic_setting" "eventhub" {
  count = var.logging_enabled == true ? 1 : 0
  name                            = "${var.name}_all_to${local.destination}"
  target_resource_id              = azurerm_eventhub_namespace.namespace.id
    
  #If sending to a LAW
  log_analytics_workspace_id      = var.log_analytics_workspace_id
  log_analytics_destination_type  = var.log_analytics_workspace_id != null ? "Dedicated" : null

  #If sending to a storage account (typically for archiving)
  storage_account_id    = var.log_storage_account_id

  #If streaming to an Event Hub (Do not stream diagnostics to the Event Hub being created by this module)
  eventhub_name                   = var.log_eventhub_name
  eventhub_authorization_rule_id  = var.log_eventhub_namespace_authorization_rule_id
  
  dynamic "log" {
    for_each = toset(["ArchiveLogs","OperationalLogs","AutoScaleLogs","KafkaCoordinatorLogs","KafkaUserErrorLogs","EventHubVNetConnectionEvent","CustomerManagedKeyUserLogs"])
    content {
      category                      = log.key

      retention_policy {
        enabled                     = false
      }
    }
    
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled                     = false
    }
  }
}
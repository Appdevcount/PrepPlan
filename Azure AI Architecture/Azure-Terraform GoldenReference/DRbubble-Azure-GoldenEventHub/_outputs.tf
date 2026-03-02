output "ns_name" {
  value = azurerm_eventhub_namespace.namespace.name
}

output "ns_id" {
  value = azurerm_eventhub_namespace.namespace.id
}

output "ns_identity" {
  value = azurerm_eventhub_namespace.namespace.identity
}

output "RootManageSharedAccessKey" {
  value = {
    "default_primary_connection_string" = azurerm_eventhub_namespace.namespace.default_primary_connection_string
     default_primary_connection_string_alias = azurerm_eventhub_namespace.namespace.default_primary_connection_string_alias
     default_primary_key = azurerm_eventhub_namespace.namespace.default_primary_key
  }
  sensitive = true
}

output "eventhub_namespace_authorization_rule_id" {
  value = [for r in azurerm_eventhub_namespace_authorization_rule.nssap: r.id]
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.endpoint[*].id
}

output "drns_name" {
  value = var.dr_location == null ? null : azurerm_eventhub_namespace.drnamespace[0].name
}

output "drns_id" {
  value = var.dr_location == null ? null : azurerm_eventhub_namespace.drnamespace[0].id
}

output "drns_identity" {
  value = var.dr_location == null ? null : azurerm_eventhub_namespace.drnamespace[0].identity
}

output "drprivate_endpoint_id" {
  value = azurerm_private_endpoint.endpoint[*].id
}
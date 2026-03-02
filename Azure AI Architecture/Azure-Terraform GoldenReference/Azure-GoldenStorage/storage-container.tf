locals {
  include_blob_private_endpoint = !var.public_network_access_enabled && length(var.pe_subnet_id) > 0 && contains(var.private_endpoints, "blob")
}

resource "time_sleep" "wait_for_private_endpoint_container" {
  depends_on = [azurerm_private_endpoint.endpoint]
  count = local.include_blob_private_endpoint ? 1 : 0
  create_duration = var.TimerDelay
}
resource azurerm_storage_container blob_container {
  for_each              = { for container in var.containers : container => container }
  depends_on            = [time_sleep.wait_for_private_endpoint_container]
  name                  = each.key
  storage_account_name  = var.name
  container_access_type = "private"
}
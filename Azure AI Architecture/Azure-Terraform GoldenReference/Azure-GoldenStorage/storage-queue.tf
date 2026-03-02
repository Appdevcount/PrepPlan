locals {
  include_queue_private_endpoint = !var.public_network_access_enabled && length(var.pe_subnet_id) > 0 && contains(var.private_endpoints, "queue")
}

resource "time_sleep" "wait_for_private_endpoint_queue" {
  depends_on = [azurerm_private_endpoint.endpoint]
  count = local.include_queue_private_endpoint ? 1 : 0
  create_duration = var.TimerDelay
}
resource azurerm_storage_queue queue {
  for_each              = { for queue in var.queues : queue => queue }
  depends_on            = [time_sleep.wait_for_private_endpoint_queue]
  name                  = each.key
  storage_account_name  = var.name
}
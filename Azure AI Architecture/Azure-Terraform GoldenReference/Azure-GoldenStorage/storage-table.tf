locals {
  include_table_private_endpoint = !var.public_network_access_enabled && length(var.pe_subnet_id) > 0 && contains(var.private_endpoints, "table")
}

resource "time_sleep" "wait_for_private_endpoint_table" {
  depends_on = [azurerm_private_endpoint.endpoint]
  count = local.include_table_private_endpoint ? 1 : 0
  create_duration = var.TimerDelay
}
resource azurerm_storage_table table {
  for_each              = { for table in var.tables : table => table }
  depends_on            = [time_sleep.wait_for_private_endpoint_table]
  name                  = each.key
  storage_account_name  = var.name
}
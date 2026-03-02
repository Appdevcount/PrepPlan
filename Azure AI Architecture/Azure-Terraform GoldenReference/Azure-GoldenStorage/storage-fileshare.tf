locals {
  include_fs_private_endpoint = !var.public_network_access_enabled && length(var.pe_subnet_id) > 0 && contains(var.private_endpoints, "file")
}

resource "time_sleep" "wait_for_private_endpoint_fs" {
  depends_on = [azurerm_private_endpoint.endpoint]
  count = local.include_fs_private_endpoint ? 1 : 0
  create_duration = var.TimerDelay
}
resource "azurerm_storage_share" "fsshare" {
  for_each             = { for file in var.files : file.name => file }
  depends_on           = [time_sleep.wait_for_private_endpoint_fs]
  name                 = each.key
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = each.value.quota 
}


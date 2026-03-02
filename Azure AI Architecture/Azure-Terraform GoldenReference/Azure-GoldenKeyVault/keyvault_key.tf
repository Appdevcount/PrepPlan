resource "time_sleep" "wait_for_access_permissions" {
  depends_on      = [azurerm_role_assignment.initial, azurerm_key_vault_access_policy.initial, azurerm_private_endpoint.keyvault]
  count           = length(var.keyvault_keys) > 0 ? 1 : 0
  create_duration = var.TimerDelay
}

resource "azurerm_key_vault_key" "key" {
  depends_on   = [time_sleep.wait_for_access_permissions]
  for_each     = var.keyvault_keys
  name         = each.key
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = each.value.key_type
  key_size     = each.value.key_size
  key_opts     = each.value.key_opts 
  tags         = local.tags
}

data "azurerm_key_vault" "tde-kv" {
  name                = var.tde_cmk_key_vault_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_key_vault_key" "tde_cmk" {
  name         = "${azurerm_mssql_managed_instance.managed_instance.name}-tde-cmk"
  key_vault_id = data.azurerm_key_vault.tde-kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "unwrapKey",
    "wrapKey",
  ]

}

resource "time_sleep" "wait_10_minutes" {
  depends_on = [ azurerm_mssql_managed_database.managed_database, azurerm_key_vault_key.tde_cmk ]

  create_duration = "10m"
}

resource "azurerm_mssql_managed_instance_transparent_data_encryption" "tde-setting" {
  managed_instance_id = azurerm_mssql_managed_instance.managed_instance.id
  key_vault_key_id    = azurerm_key_vault_key.tde_cmk.id
  depends_on          = [time_sleep.wait_10_minutes]
}

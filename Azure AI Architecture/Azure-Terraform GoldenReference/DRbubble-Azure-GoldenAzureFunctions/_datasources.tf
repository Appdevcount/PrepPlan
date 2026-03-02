data azurerm_storage_account_sas functionsas {
  connection_string = module.source_code_storage.storage_account.primary_connection_string
  https_only = true
  start = var.sas_start_date
  expiry = var.sas_expiry_date

  resource_types {
    container = false
    object = true
    service = false
  }

  services {
    blob = true
    file = false
    queue = false
    table = false
  }

  permissions {
    add = false
    create = false
    delete = false
    list = false
    process = false
    read = true
    update = false
    write = false
  }
}

data azurerm_monitor_diagnostic_categories function_diagnostic_catagories {
  count = var.monitor_log_storage_account_id == null ? 0 : 1

  resource_id = azurerm_function_app.function.id
}
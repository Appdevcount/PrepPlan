resource azurerm_function_app function {
  name = var.name

  resource_group_name = var.resource_group_name
  location = var.location

  version = 3
  app_service_plan_id = var.app_service_plan_id
  storage_account_name = module.source_code_storage.storage_account_name
  storage_account_access_key = module.source_code_storage.storage_account.primary_access_key

  os_type = var.os_type == "windows" ? null : var.os_type
  https_only = true

  tags = local.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = true
    http2_enabled = true
    min_tls_version = "1.2"
  }

  app_settings = merge(var.app_settings, {
    "FUNCTIONS_WORKER_RUNTIME": var.function_runtime,
    "FUNCTIONS_WORKER_PROCESS_COUNT": var.worker_process_count,
    "WEBSITE_RUN_FROM_PACKAGE": local.package_sas,
    "APPLICATIONINSIGHTS_CONNECTION_STRING": azurerm_application_insights.function_insights.connection_string,
    "APPINSIGHTS_INSTRUMENTATIONKEY": azurerm_application_insights.function_insights.instrumentation_key
  })

  lifecycle {
    ignore_changes = [ os_type ]
  }

  provisioner local-exec {
    command = "az functionapp restart -n ${azurerm_function_app.function.name} -g ${var.resource_group_name}"
  }
}

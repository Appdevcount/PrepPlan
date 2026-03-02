module source_code_storage {
  source = var.source_code_storage_source

  name = "${var.name}-sa"
  resource_group_name = var.resource_group_name

  account_tier = "Standard"
  account_replication_type = "LRS"
  access_tier = "Hot"

  allowed_public_ips = var.allowed_public_ips

  allowed_subnet_ids = var.allowed_subnet_ids

  monitor_log_storage_account_id = var.monitor_log_storage_account_id

  tags = local.data_tags
}

resource azurerm_storage_container source_code_container {
  name = "${var.name}-blob"
  storage_account_name = module.source_code_storage.storage_account_name
}

resource azurerm_storage_blob blob {
  depends_on = [ null_resource.artifactory_artifact ]

  name                        = "${var.name}.zip"
  storage_account_name        = module.source_code_storage.storage_account_name
  storage_container_name      = azurerm_storage_container.source_code_container.name
  type                        = "Block"

  source = local.local_filename
}

locals {
  tags = merge(
    var.required_tags,
    var.optional_tags,
  )
  data_tags = merge(
    var.required_tags,
    var.required_data_tags,
    var.optional_tags,
    var.optional_data_tags,
  )
  local_filename = "${path.root}/${replace(timestamp(), ":", "-")}-${var.artifact}"
  sa_name = module.source_code_storage.storage_account_name
  sc_name = azurerm_storage_container.source_code_container.name
  b_name = azurerm_storage_blob.blob.name
  package_sas = "https://${local.sa_name}.blob.core.windows.net/${local.sc_name}/${local.b_name}${data.azurerm_storage_account_sas.functionsas.sas}"
}
locals {
 
  tags = merge(
    var.required_tags,
    var.optional_tags,
    var.required_data_tags,
    var.optional_data_tags
  ) 

  enable_private_dns_zone_group = data.azurerm_client_config.current.tenant_id == "595de295-db43-4c19-8b50-183dfd4a3d06" ? false : true
}
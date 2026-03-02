# This file should only contain local variable declarations that are used globally within a module. If
# a local is defined to support creation of a specific resource, that local should be included in the same
# .tf file as the resource being created to improve code readability.

locals {
 
  tags = merge(
    var.required_tags,
    var.optional_tags,
    var.required_data_tags,
    var.optional_data_tags
  ) 

  data_tags = merge(
    var.required_tags,
    var.optional_tags,
    var.required_data_tags,
    var.optional_data_tags
  )

  enable_private_dns_zone_group = data.azurerm_client_config.current.tenant_id == "595de295-db43-4c19-8b50-183dfd4a3d06" ? false : true

}

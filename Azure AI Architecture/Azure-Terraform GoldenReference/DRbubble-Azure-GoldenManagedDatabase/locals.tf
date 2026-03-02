locals {

  env = data.azurerm_mssql_managed_instance.managed_instance.tags.Environment
  
  is_prod = local.env == "prod" ? true : false
  
  short_term_retention_days = local.is_prod ?  15 : 8
  
  tags = merge(
    {
      Environment = local.env
    },
    var.required_tags,
    var.optional_tags,
  )
}

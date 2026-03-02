locals {
  naming_prefix                 = "${var.prefix}-${var.environment}-${var.managed_instance_name}"
  dba_managed_database_name     = "CIGWORKS"
  is_prod                       = var.environment == "prod" ? true : false
  maintenance_name              = local.is_prod ? "SQL_EastUS_MI_2" : "SQL_Default"
  short_term_retention_days     = local.is_prod ?  15 : 8
  tags = merge(
    {
      Environment = var.environment
    },
    var.required_tags,
    var.optional_tags,
  )
}

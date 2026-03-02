module "managed_instance" {
    
    source                    = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenManagedDatabase.git"
    
    subscription_id           = var.subscription_id
    sql_managed_database_name = var.sql_managed_database_name
    sql_managed_instance_name = var.sql_managed_instance_name
    resource_group_name       = var.resource_group_name
    required_tags             = var.required_tags
    optional_tags             = var.optional_tags
}

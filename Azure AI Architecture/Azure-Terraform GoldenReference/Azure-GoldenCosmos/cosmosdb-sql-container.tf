resource "azurerm_cosmosdb_sql_container" "container" {
  depends_on          = [azurerm_cosmosdb_sql_database.database]
  for_each            = var.db_container_configurations
  resource_group_name = var.resource_group_name 
  account_name        = local.cosmos_acct_name  
  database_name       = var.cosmos_database_name  
  default_ttl         = each.value.default_ttl  
  name                = each.key                  
  partition_key_path  = "/${each.value.partition_key_path}"
  partition_key_version = each.value.partition_key_version
  throughput          = each.value.throughput > 0 ? each.value.throughput : null

  dynamic "autoscale_settings" {
    for_each = each.value.auto_scale_max_throughput > 0 ? ["add_autoscale_throughput"] : []

    content {
       max_throughput = each.value.auto_scale_max_throughput
    }
  }

  indexing_policy {

    indexing_mode = "consistent"

    dynamic "included_path" {
      for_each = each.value.included_paths
      content {
        path =  included_path.value
      }  
      
    }

    dynamic "excluded_path" {
        for_each = each.value.excluded_paths
        content {
          path = excluded_path.value
        }
      }

    dynamic "composite_index" {
        for_each = each.value.composite_indexes

        content {
          dynamic "index" {
            for_each = composite_index.value

            content {
              path  = index.value.path
              order = index.value.order
            }
          }

        }
      }
  }
 
  unique_key {
      paths =  each.value.unique_keys
    }

  conflict_resolution_policy {
    mode                     = "LastWriterWins"
    conflict_resolution_path = "/_ts"
  }

  lifecycle {
       ignore_changes = [throughput, unique_key]
    }
}
  

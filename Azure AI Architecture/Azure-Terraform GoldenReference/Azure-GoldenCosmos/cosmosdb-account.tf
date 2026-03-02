locals {
  prefix_name      = var.prefix_name != "" ? format("%s%s", var.prefix_name, "-") : ""
  location_abbr    = var.location_abbr != "" ? format("%s%s", var.location_abbr, "-") : ""
  environment      = var.environment != "" ? format("%s%s", var.environment, "-") : ""
  cosmos_acct_name = format("%s%s%s%s", local.prefix_name, local.location_abbr, local.environment, var.cosmos_account_name)
  capabilities     = var.serverless ? [{ name = "EnableServerless" }] : var.capabilities
  ip_range_portal  = var.enable_azure_portal_access ? var.portal_access_ip_range_filter : ""
  #ip_range_dc          = var.enable_azure_dc_access ? "0.0.0.0" : ""
  ip_range_filter  = join(",", compact([var.allowed_ip_range_filter, local.ip_range_portal]))
  backup           = {
                      type = var.enable_continuous_backup ? "Continuous" : "Periodic"
                      interval_in_minutes = var.enable_continuous_backup ? null : var.backup_policy.interval_in_minutes
                      retention_in_hours  = var.enable_continuous_backup ? null : var.backup_policy.retention_in_hours
                      storage_redundancy  = var.enable_continuous_backup ? null : var.backup_policy.storage_redundancy 
                     }
}

resource "azurerm_cosmosdb_account" "account" {
  name                               = local.cosmos_acct_name
  location                           = var.location
  resource_group_name                = var.resource_group_name
  offer_type                         = "Standard"
  kind                               = var.kind
  enable_automatic_failover          = var.enable_automatic_failover
  enable_free_tier                   = var.enable_free_tier
  enable_multiple_write_locations    = var.enable_multiple_write_locations
  access_key_metadata_writes_enabled = var.access_key_metadata_writes_enabled
  tags                               = local.tags
  
  identity {
    type = var.identity_type
    identity_ids = var.user_identities
  }
  
  key_vault_key_id  = var.enable_customer_managed_key ? var.keyvault_encryption_key_id : null
  default_identity_type = var.enable_customer_managed_key ? join("=", ["UserAssignedIdentity", var.user_identities[0]]) : null


  dynamic "capabilities" {
    for_each = local.capabilities

    content {
      name = capabilities.value.name
    }
  }

  dynamic "geo_location" {
    for_each = var.failover_geo_locations

    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
    }
  }

  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.max_interval_in_seconds
    max_staleness_prefix    = var.max_staleness_prefix
  }

  backup {
    type = local.backup.type
    interval_in_minutes = local.backup.interval_in_minutes
    retention_in_hours = local.backup.retention_in_hours
    storage_redundancy = local.backup.storage_redundancy
  }


  public_network_access_enabled = var.public_network_access_enabled
  dynamic "virtual_network_rule" {
    for_each = var.vnet_subnets

    content {
      id = virtual_network_rule.value
    }
  }

   ip_range_filter                   = local.ip_range_filter
   is_virtual_network_filter_enabled = length(var.vnet_subnets) > 0 ? true : false


  lifecycle {
    precondition {
      condition    = var.public_network_access_enabled ? length(var.allowed_ip_range_filter) > 0 || length(var.vnet_subnets) > 0 : true 
      error_message = "Cosmos Firewall Rules are required. Add 1 or more 'allowed_ip_range_filter' IPs, and\\or allowed vnet_subnets."
    }

    precondition {
      condition    = var.enable_customer_managed_key ? length(var.user_identities) > 0 && length(var.keyvault_encryption_key_id) > 0 : true 
      error_message = "When enabling Customer Managed Keys, you must include a User Managed Identity ID and Key Vault Key ID."
    }

    precondition {
      condition    = var.enable_default_alerting ? length(var.alarm_funnel_id) > 0 : true 
      error_message = "Alarm Funnel Action Group ID is required when enabling the default alerts."
    }

    precondition {
      condition    = !var.public_network_access_enabled ? length(var.private_endpoint_subnet_id) > 0 : true 
      error_message = "A Private Endpoint subnet Id is required when disabling public network access."
    }
    
  }


}

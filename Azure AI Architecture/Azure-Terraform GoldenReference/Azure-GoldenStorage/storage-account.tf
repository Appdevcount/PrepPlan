
locals {
  identity_ids = var.identity_type == "SystemAssigned" ? [] : var.user_assigned_identity_ids
  enable_static_website = var.static_website.index_document != null
}

resource azurerm_storage_account storage_account {
  name                              = var.name
  resource_group_name               = var.resource_group_name
  enable_https_traffic_only         = true
  min_tls_version                   = "TLS1_2"
  allow_nested_items_to_be_public   = false
  cross_tenant_replication_enabled  = var.cross_tenant_replication_enabled
  location                          = var.location
  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  account_kind                      = var.account_kind
  access_tier                       = var.access_tier
  shared_access_key_enabled         = var.shared_access_key_enabled
  default_to_oauth_authentication   = var.shared_access_key_enabled ? var.default_to_oauth_authentication : true
  large_file_share_enabled          = var.large_file_share_enabled 
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  tags                              = local.tags

  identity {
    type = var.identity_type
    identity_ids = local.identity_ids
  }

  # network rules will be required per policy: 
  network_rules {
      default_action             = var.public_network_access_enabled && length(var.allowed_public_ips) == 0 && length(var.allowed_subnet_ids) == 0 ? "Allow" : "Deny"
      bypass                     = var.network_rule_bypass
      virtual_network_subnet_ids = var.public_network_access_enabled ? var.allowed_subnet_ids : null
      ip_rules                   = var.public_network_access_enabled ? var.allowed_public_ips : []
  }

  # sas policy required per policy: 
  sas_policy {
    expiration_period = var.sas_expiration_period_policy
    expiration_action = "Log"
  }
  
  # Enable Azure Data Lake Storage Gen 2
  is_hns_enabled                    = var.is_hns_enabled

  #  Data protection options
  blob_properties {
      versioning_enabled            = var.blob_data_protection_properties.versioning_enabled
      change_feed_enabled           = var.blob_data_protection_properties.change_feed_enabled
      change_feed_retention_in_days = var.blob_data_protection_properties.change_feed_retention_in_days
      last_access_time_enabled      = var.blob_data_protection_properties.last_access_time_enabled

      dynamic delete_retention_policy {
        for_each = var.blob_data_protection_properties.enable_delete_retention_policy ? ["add_delete_retention_policy"] : []
        content {
          days = var.blob_data_protection_properties.delete_retention_policy
        }
        
      }

      dynamic container_delete_retention_policy {
        for_each = var.blob_data_protection_properties.enable_container_delete_retention_policy ? ["add_container_delete_retention_policy"] : []
        content {
          days = var.blob_data_protection_properties.container_delete_retention_policy
        }
        
      }
  }

  # Enable static website
  dynamic static_website {
    for_each = local.enable_static_website ? ["enable_static_website"] : []
    content {
      index_document = var.static_website.index_document
      error_404_document = var.static_website.error_404_document 
    }

  }

  lifecycle {
    precondition {
      condition    = var.public_network_access_enabled ? true : length(var.private_endpoints) > 0 && length(var.pe_subnet_id) > 0
      error_message = "Private Endpoints are required when public_network_access_enabled is set to false."
    }
    precondition {
      condition     = strcontains(var.identity_type, "UserAssigned") ? length(var.user_assigned_identity_ids) > 0 : true
      error_message = "If Identity Type = UserAssigned, at least one User Assigned Identity ID is required."
    }
    precondition {
      condition     =  var.account_kind == "StorageV2" ||  var.account_tier == "Premium" 
      error_message = "Customer managed key requires account_kind = StorageV2 OR access_tier = Premium."
    }
    precondition {
      condition     = var.infrastructure_encryption_enabled ? var.account_kind == "StorageV2" ||  (var.account_tier == "Premium" && var.account_kind == "BlockBlobStorage") : true
      error_message = "Infrastructure encryption requires account_kind = StorageV2 OR (access_tier = Premium and account_kind = BlockBlobStorage."
    }
    precondition {
      condition     = local.enable_static_website ?  var.account_kind == "StorageV2" ||  var.account_kind == "BlockBlobStorage" : true
      error_message = "To enable Static Website the account_kind must be either StorageV2 or BlockBlobStorage."
    }
    precondition {
      condition     = var.is_hns_enabled ? var.account_tier == "Standard" ||  (var.account_tier == "Premium" && var.account_kind == "BlockBlobStorage") : true
      error_message = "To enable Azure Data Lake Storage Gen 2 either the access_tier must be Standard OR (account_tier = Premium AND account_kind = BlockBlobStorage)."
    }
    precondition {
      condition     =  length(var.files) > 0 ? var.shared_access_key_enabled  : true
      error_message = "To add File Shares, Shared Access Keys MUST be enable."
    }
    precondition {
      condition     =  length(var.tables) > 0 ? var.shared_access_key_enabled  : true
      error_message = "To add Tables, Shared Access Keys MUST be enable."
    }

    ignore_changes = [customer_managed_key]
    
  }
  
}


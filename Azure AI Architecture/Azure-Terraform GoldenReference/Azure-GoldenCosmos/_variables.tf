#Standard variables that appear in all modules
variable "resource_group_name" {
  description = "Required: Resource group to deploy in"
  type        = string
}

variable "environment" {
  description = "Required: The name of the environment for the resource. Such as dv1, in1, pd1"
  type        = string
  default     = ""
}

variable "location" {
  description = "Required: Region to deploy to"
  type        = string
  default     = ""
  validation {
     condition     = var.location == null ? false : length(var.location) > 0 
     error_message = "Variable: location is required."
    }   
}

variable "location_abbr" {
  description = "Optional: Region to deploy to in abbreviated format. eu, eu2, cus etc."
  type        = string
  default     = ""
}

variable "prefix_name" {
  description = "Optional: Can be used for any resource name."
  type        = string
  default     = ""
}
variable "suffix_name" {
  description = "Optional: Can be used for any resource name. Reference: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations"
  type        = string
  default     = ""
}
variable "cosmos_account_name" {
  description = "Required: The name of the Cosmos Account."
  type    = string
  default = ""
  validation {
     condition     = var.cosmos_account_name == null ? false : length(var.cosmos_account_name) > 0 
     error_message = "Variable: cosmos_account_name is required."
    }   
}

variable "cosmos_database_name" {
  description = "Required: The name of Cosmos Database"
  type = string
  default = ""
  validation {
     condition     = var.cosmos_database_name == null ? false : length(var.cosmos_database_name) > 0 
     error_message = "Variable: cosmos_database_name is required."
    }  
}

/* Note, "required_tags" and "optional_tags" are combined into a single local variable "tags". 
   Reference the local variable when creating resources.                                            */

variable "required_tags" {
  description = "Required: Mandatory Tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements)"
  type = object({
    AssetOwner          = string
    CostCenter          = string
    ServiceNowAS        = string
    ServiceNowBA        = string
    SecurityReviewID    = string
  })
  validation {
    condition     = var.required_tags.AssetOwner != "" && var.required_tags.CostCenter != ""  && var.required_tags.ServiceNowAS != "" && var.required_tags.ServiceNowBA != "" && var.required_tags.SecurityReviewID != ""
    error_message = "Defining all tags is required for this resource (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)."
  }
}

variable "optional_tags" {
  description = "Optional: Standard tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)"
  type        = map(string)
  default     = {}
}

/* 
Cloud services that hold or store data require some additional tags. If you are using any Cloud service that may store or hold data, uncomment
these variables in addition to standard tagging variables above. IMPORTANT NOTE -- update _locals.tf as well, if data tags are used, to create
local variable data_tags.
*/
variable "required_data_tags" {
  description = "Required: Tags for data at rest (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)"
  type = object({
    DataSubjectArea         = string
    ComplianceDataCategory  = string
    DataClassification      = string
    BusinessEntity          = string
    LineOfBusiness          = string
  })
  validation {
    condition = var.required_data_tags.DataSubjectArea != "" && var.required_data_tags.ComplianceDataCategory != "" && var.required_data_tags.DataClassification != "" && var.required_data_tags.BusinessEntity != "" && var.required_data_tags.LineOfBusiness != ""
    error_message = "Defining all tags is required for this resource (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)."
  }
}

variable "optional_data_tags" {
  description = "Optional: Tags for data (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)"
  type        = map(string)
  default     = {}
}


#Add additional variables as needed
#Variable name will typically match Terraform resource parameter name

variable "identity_type" {
  description = "Required: If using CMK otherwise Optional: The Type of Managed Identity assigned to this Cosmos account. Possible values are SystemAssigned, UserAssigned and SystemAssigned, UserAssigned."
  type        = string
  default     = "SystemAssigned"
}

variable "enable_customer_managed_key" {
  description = "Optional: Use Customer Managed Key for data at rest encryption"
  type = bool
  default = false
}

variable "user_identities" {
  description = "Required if using CMK otherwise Optional: Specifies a list of User Assigned Managed Identity IDs to be assigned to this Cosmos Account."
  type        = list(string)
  default     = []

   validation {
    condition     = var.user_identities != null ? true : false
    error_message = "Variable: user_identities cannot be null. Empty [] is allowed."
  }
}

variable "keyvault_encryption_key_id" {
  description = "Required if using CMK otherwise Optional: Name of Key Vault encryption key name"
  type        = string
  default     = ""

    validation {
    condition     = var.keyvault_encryption_key_id != null ? true : false
    error_message = "Variable: keyvault_encryption_key_id cannot be null. Empty string is allowed."
  }
}

variable "kind" {
  description = "Optional: Specifies the Kind of CosmosDB to create - possible values are GlobalDocumentDB, MongoDB and Parse"
  type = string
  default = "GlobalDocumentDB"
}

variable "enable_free_tier" {
  description = "Optional: Enable the Free Tier pricing option for this Cosmos DB account."
  type = bool
  default = false
}

variable "enable_automatic_failover" {
  description = "Optional: Enable automatic failover for this Cosmos DB account."
  type = bool
  default = false
} 

variable "enable_multiple_write_locations" {
  description = "Optional: Enable multiple write locations for this Cosmos DB account."
  type = bool
  default = false
} 

variable "failover_geo_locations" {
  description = "Required: Specifies a geo_location resource, used to define where data should be replicated with the failover_priority 0 specifying the primary location."
  default = []
  type = list(object({
    location          = string
    failover_priority = number
    zone_redundant    = bool
  }))

}

variable "serverless" {
  description = "Optional: Flag to configure the account for serverless throughput."
  type        = bool
  default     = false
}

variable "capabilities" {
  description = "Optional: Configures the capabilities to be enabled for this Cosmos DB account."
  type = list(object({
    name = string
  }))
  default = []
}

variable "enable_continuous_backup" {
  description = "Optional: Flag to use Continuous Backup Policy."
  type = bool
  default = false
}
variable "backup_policy" {
  description = "Optional: Backup Policy. Type must be Periodic or Continuous"
  type = object({
    type = string
    interval_in_minutes = optional(number, null)
    retention_in_hours  = optional(number, null)
    storage_redundancy  = optional(string, null)
  })
  default = {
      type = "Periodic"
      interval_in_minutes = 240
      retention_in_hours = 8
      storage_redundancy = "Geo"
  }
}

variable "consistency_level" {
  description = "Optional: Defines the consistency level for this CosmosDB account."
  type        = string
  default     = "Session"
}

variable "max_interval_in_seconds" {
  description = "Optional: When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated. Accepted range for this value is 5 - 86400 (1 day). Defaults to 5. Required when consistency_level is set to BoundedStaleness."
  type        = number
  default     = 5
}

variable "access_key_metadata_writes_enabled" {
  description = "Enables write operations on metadata resources (databases, containers, throughput) via account keys. https://learn.microsoft.com/en-us/azure/cosmos-db/audit-control-plane-logs#disable-key-based-metadata-write-access"
  type        = bool
  default     = true
}
variable "max_staleness_prefix" {
  description = "Optional: When used with the Bounded Staleness consistency level, this value represents the number of stale requests tolerated. Accepted range for this value is 10 - 2147483647. Defaults to 100. Required when consistency_level is set to BoundedStaleness."
  type        = number
  default     = 100
}


variable "vnet_subnets" {
  description = "Required if no IP Range filters used otherwise Optional: A list of vnets to integrate"
  type        = list(string)
  default     = []

}

variable "public_network_access_enabled" {
  description = "Optional: Whether or not public network access is allowed."
  type        = bool
  default     = true
}

variable "allowed_ip_range_filter" {
  description = "Required if no VNet Integration subnets used otherwise Optional. List of public IP or IP ranges in CIDR Format."
  type        = string
  default     = "199.204.156.0/22,198.27.9.0/24"

  validation {
    condition     = var.allowed_ip_range_filter != null ? !strcontains(var.allowed_ip_range_filter, "0.0.0.0") : true
    error_message = "IP 0.0.0.0 is not allowed. Reference variable: allowed_ip_range_filter."
  }
}

variable "enable_azure_portal_access" {
  description = "Optional: Flag used for enabling the portal access setting in Cosmos firewall (networking) blade."
  type    = bool
  default = false
}

variable "portal_access_ip_range_filter" {
  description = "Optional: https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-configure-firewall#allow-requests-from-the-azure-portal"
  type        = string
  default     = "104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26"

  validation {
    condition     = !strcontains(var.portal_access_ip_range_filter, "0.0.0.0")
    error_message = "IP 0.0.0.0 is not allowed. Reference variable: portal_access_ip_range_filter."
  }
}


variable "auto_scale_max_throughput" {
  description = "Optional: The maximum throughput for autoscaling. Must be increments of 1000."
  type = number
  default = 4000
}


variable "db_container_configurations" {
  description = "Required: Used for creating one or more Containers."
  type = map(object({
    default_ttl               = number
    partition_key_path        = string
    partition_key_version     = optional(number, 1)
    throughput                = optional(number, 0)
    auto_scale_max_throughput = optional(number, 0)
    indexing_mode             = optional(string, "consistent")
    included_paths            = optional(list(string), ["/*"])
    excluded_paths            = optional(list(string), [])
    composite_indexes         = optional(list(list(object({ path = string, order = string }))), [])
    unique_keys               = optional(list(string), [])
  }))

 validation {
   condition  = length(var.db_container_configurations) > 0 ? alltrue([ for tp in var.db_container_configurations : !(tp.throughput > 0 && tp.auto_scale_max_throughput > 0) ])  : true                                                   
   error_message = "One or more container settings is using both throughput and auto_scale_max_throughput. These two settings cannot be used together."
  }
 validation {
   condition  = length(var.db_container_configurations) > 0 ? alltrue([ for tp in var.db_container_configurations : !(tp.throughput == 0 && tp.auto_scale_max_throughput == 0) ])  : true                                                   
   error_message = "One or more container settings requires either a throughput value or auto_scale_max_throughput value."
  } 
}

variable "cosmosdb_diagnostics_settings" {
    description     = "Required: List of diagnostic settings"
    type = list(object({
        name                              = string,
        log_analytics_workspace_id        = optional(string, null)
        storage_id                        = optional(string, null)
        eventhub_authorization_rule_id    = optional(string, null)
        eventhub_name                     = optional(string, null)
        include_diagnostic_metric_categories = bool  
    }))
/*     default = [{
      name                           = "ToPd1-CloudSIEM"  
      log_analytics_workspace_id     = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_security_siem/providers/Microsoft.OperationalInsights/workspaces/pd1-cloudsiem"
      storage_id                     = null
      eventhub_authorization_rule_id = null
      eventhub_name                  = null
      include_diagnostic_log_categories = true
      include_diagnostic_metric_categories = true  
     }] */
    validation {
    condition     = length(var.cosmosdb_diagnostics_settings) > 0 ? true : false
    error_message = "At least one comosdb diagnostic setting is required."
    }

    validation {
      condition     = !alltrue([for lc in var.cosmosdb_diagnostics_settings : (lc.log_analytics_workspace_id == null || lc.log_analytics_workspace_id == "") && (lc.storage_id == null || lc.storage_id == "") && ((lc.eventhub_authorization_rule_id == null || lc.eventhub_authorization_rule_id == "") && (lc.eventhub_name == null || lc.eventhub_name == "")) ])
      error_message = "At least one diagnostic destination setting required. (log_analytics_workspace_id or storage_id or (eventhub_name and eventhub_authorization_rule_id )"
    } 

}

variable "enable_default_alerting" {
  description = "Optional: Enable default alerts."
  type    = bool
  default = true
}

variable "alert_environment" {
  description = "Required if enabling default alerts. The name of the environment for the resource. Such as SANDBOX, DEV, PROD. Reference: https://confluence.sys.cigna.com/display/CLOUD/Alarm+Funnel+-+Azure"
  type        = string
  default     = "DEV"
  validation {
    condition     = contains(["SANDBOX", "DEV", "PROD"], var.alert_environment)
    error_message = "The alert_environment must be either 'SANDBOX' or 'DEV' or 'PROD'."
  }

}

variable "alarm_funnel_id" {
  description = "Required if enabling default alerts otherwise Optional: Alert Funnel Action Group Resource Id"
  type    = string
  default = ""
/*   validation {
    condition     = var.alarm_funnel_id != null ? length(var.alarm_funnel_id) > 0 : false
    error_message = "Alarm Funnel ID is required. Reference variable: alarm_funnel_id"
  } */
}

variable "private_endpoint_subnet_id" {
  description = "Optional: The subnet id used for the Private Endpoint IPs"
  type = string
  default = ""
  validation {
    condition     = var.private_endpoint_subnet_id == null ? false : true
    error_message = "Variable private_endpoint_subnet_id cannot be null. Empty string is allowed."
    }
}

variable "private_dns_zone_id" {
  description = "Required if enabling Private Endpoints only on Cigna tenant."
  type = string
  default = ""
  validation {
    condition     = var.private_dns_zone_id == null ? false : true
    error_message = "Variable private_dns_zone_id cannot be null. Empty string is allowed."
    }

}



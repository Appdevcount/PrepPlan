variable resource_group_name {
  description = "Name of resource group in which the storage account will be created."
  type        = string
}
variable name {
  description = "Name of the storage account  created"
  type        = string
}
variable identity_type {
  description = "Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned (to enable both)."
  type        = string
  default     = "SystemAssigned"

    validation {
    condition     =  var.identity_type == "SystemAssigned" || var.identity_type == "UserAssigned"
    error_message = "Identity Type must be either SystemAssigned or UserAssigned"
  }  
}
variable location {
  description = "Region of the resource group"
  type        = string
}

variable "cross_tenant_replication_enabled" {
    description = "Should cross Tenant replication be enabled."
    type        = bool
    default     = false  
}

variable account_kind {
  description = "Account kind for the created storage account (BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2). Changing this forces a new resource to be created."
  type        = string
  default     = "StorageV2"
}
variable account_tier {
  description = "Account tier for the created storage account (Standard, Premium.)"
  type        = string
  default     = "Standard"
}
variable account_replication_type {
  description = "Account replication type for the created storage account (LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS)."
  type        = string
  default     = "GRS"
}
variable access_tier {
  description = "Storage account access tier (Hot, Cool, Archive)."
  type        = string
  default     = "Hot"
}
variable shared_access_key_enabled {
  description = "Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key."
  type        = bool
  default     = true
}
variable default_to_oauth_authentication {
  description = "Default to Azure Active Directory authorization in the Azure portal."
  type        = bool
  default     = false
}

# Networking settings
variable public_network_access_enabled {
    description = "Whether the public network access is enabled. If disabled, private endpoints are required."
    type        = bool
    default     = true
}
variable allowed_public_ips {
  description = "List of public IP or IP ranges in CIDR Format. Public Network Access = true this variable or allowed_public_ips is required."
  type        = list(string)
  default = []
}
variable allowed_subnet_ids {
  description = "A list of resource ids for subnets. Public Network Access = true this variable or allowed_public_ips is required."
  type        = list(string)
  default     = []
}
variable network_rule_bypass {
  description = "A list of trusted Microsoft services to bypass the network rules. https://gsl.dome9.com/D9.AZU.NET.25.html"
  type        = list(string)
  default     =  ["AzureServices"]
}

#SAS Keys
# https://learn.microsoft.com/en-us/azure/storage/common/sas-expiration-policy?tabs=azure-portal&WT.mc_id=Portal-Microsoft_Azure_Storage
variable sas_expiration_period_policy {
  description = "Upper limit for SAS expiry interval."
  type        = string
  default     = "00.06:00:00"  
}

# https://learn.microsoft.com/en-us/azure/storage/blobs/soft-delete-blob-overview
variable "blob_data_protection_properties" {
  description = "Blob properties"
  type = object({
    enable_delete_retention_policy           = bool
    delete_retention_policy                  = number
    versioning_enabled                       = bool
    last_access_time_enabled                 = bool
    enable_container_delete_retention_policy = bool
    container_delete_retention_policy        = number
    change_feed_enabled                      = bool
    change_feed_retention_in_days            = number
  })

  default = {
      enable_delete_retention_policy           = true
      delete_retention_policy                  = 7
      versioning_enabled                       = true
      last_access_time_enabled                 = true
      enable_container_delete_retention_policy = true
      container_delete_retention_policy        = 7
      change_feed_enabled                      = false
      change_feed_retention_in_days            = null
    }
  
  validation {
    condition     =  var.blob_data_protection_properties.enable_delete_retention_policy ? var.blob_data_protection_properties.delete_retention_policy >= 1 &&  var.blob_data_protection_properties.delete_retention_policy < 365 : true
    error_message = "Blob delete_retention_policy value must be between 1 and 365."
  }  
  validation {
    condition     =   var.blob_data_protection_properties.enable_container_delete_retention_policy ? var.blob_data_protection_properties.container_delete_retention_policy >= 1 &&  var.blob_data_protection_properties.container_delete_retention_policy < 365 : true
    error_message = "Blob container_delete_retention_policy value must be between 1 and 365."
  }  
  validation {
    condition     =   var.blob_data_protection_properties.change_feed_enabled && var.blob_data_protection_properties.change_feed_retention_in_days != null ? var.blob_data_protection_properties.change_feed_retention_in_days >= 1 &&  var.blob_data_protection_properties.change_feed_retention_in_days < 146000 : true
    error_message = "Blob change_feed_retention_in_days value must be between 1 and 146000."
  }  
}
variable is_hns_enabled {
  description = "Enable Azure Data Lake Storage Gen 2. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}
variable static_website {
  description = "Enable static website"
  type = object({
    index_document     = string
    error_404_document = string
  })

  default = {
      index_document     = null
      error_404_document = null
    }
}
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

/* variable "diagnostics_settings_all" {
    description     = "List of diagnostic settings at storage account level."
    type = list(object({
        name                                 = optional(string, "")
        log_analytics_workspace_id           = optional(string, null),
        storage_account_id                   = optional(string, null),
        eventhub_authorization_rule_id       = optional(string, null),
        eventhub_name                        = optional(string, null),
        include_diagnostic_metric_categories = optional(bool, true)  
    }))
    default = [{}]
} */

variable "storage_diagnostics_settings" {
    description     = "List of diagnostic settings at storage account level."
    type = list(object({
        name                                 = string,
        log_analytics_workspace_id           = optional(string, null),
        storage_account_id                   = optional(string, null),
        eventhub_authorization_rule_id       = optional(string, null),
        eventhub_name                        = optional(string, null),
        include_diagnostic_metric_categories = optional(bool, true)  
    }))

    validation {
    condition     = length(var.storage_diagnostics_settings) > 0 ? true : false
    error_message = "At least one storage diagnostic setting is required."
    }

}
variable "blob_diagnostics_settings" {
    description     = "List of diagnostic settings at Blob Container level."
    type = list(object({
        name                                 = string,
        log_analytics_workspace_id           = optional(string, null),
        storage_account_id                   = optional(string, null),
        eventhub_authorization_rule_id       = optional(string, null),
        eventhub_name                        = optional(string, null),
        include_diagnostic_metric_categories = optional(bool, true)  
    }))

    validation {
    condition     = length(var.blob_diagnostics_settings) > 0 ? true : false
    error_message = "At least one blob diagnostic setting is required."
    }
}
variable "file_diagnostics_settings" {
    description     = "List of diagnostic settings at File level."
    type = list(object({
        name                                 = string,
        log_analytics_workspace_id           = optional(string, null),
        storage_account_id                   = optional(string, null),
        eventhub_authorization_rule_id       = optional(string, null),
        eventhub_name                        = optional(string, null),
        include_diagnostic_metric_categories = optional(bool, true)  
    }))
    validation {
    condition     = length(var.file_diagnostics_settings) > 0 ? true : false
    error_message = "At least one file diagnostic setting is required."
    }
}
variable "queue_diagnostics_settings" {
    description     = "List of diagnostic settings at Queue level."
    type = list(object({
        name                                 = string,
        log_analytics_workspace_id           = optional(string, null),
        storage_account_id                   = optional(string, null),
        eventhub_authorization_rule_id       = optional(string, null),
        eventhub_name                        = optional(string, null),
        include_diagnostic_metric_categories = optional(bool, true)  
    }))
    validation {
    condition     = length(var.queue_diagnostics_settings) > 0 ? true : false
    error_message = "At least one queue diagnostic setting is required."
    }
}
variable "table_diagnostics_settings" {
    description     = "List of diagnostic settings at Table level."
    type = list(object({
        name                                 = string,
        log_analytics_workspace_id           = optional(string, null),
        storage_account_id                   = optional(string, null),
        eventhub_authorization_rule_id       = optional(string, null),
        eventhub_name                        = optional(string, null),
        include_diagnostic_metric_categories = optional(bool, true)  
    }))
    validation {
    condition     = length(var.table_diagnostics_settings) > 0 ? true : false
    error_message = "At least one table diagnostic setting is required."
    }
}
##### STORAGE CONTAINER VARIABLES #####
variable "containers" {
    description = "List of BlobContainers to create"
    type        = list(string)
    default     = []
}
##### STORAGE FILE VARIABLES #####
variable "files" {
    description     = "List of Files to create"
    type = list(object({
        name        = string,
        quota       = number
    }))
    default = []
}

variable large_file_share_enabled {
  description = "This field enables the storage account for file shares spanning up to 100 TiB. Enabling this feature will limit your storage account to only locally redundant and zone redundant storage options. Once a GPv2 storage account has been enabled for large file shares, you cannot disable the large file share capability."
  type        = bool
  default     = false
}

##### STORAGE TABLES VARIABLES #####
variable "tables" {
    description  = "List of Tables to create."
    type         = list(string)
    default      = []
}
##### STORAGE QUEUES VARIABLES #####
variable "queues" {
    description = "List of Queues to create."
    type        = list(string)
    default     = []
}
##### Key Vault \ User Assigned Identity variables for Customer Managed Key feature ####
variable "infrastructure_encryption_enabled" {
  description = "Is infrastructure encryption enabled? Changing this forces a new resource to be created." 
  type    = bool
  default = false
}

variable "cmk_keyvault" {
  description = "Key Vault information for setting up Storage Account CMK"
  type = object({
                    
                    #These set of variables are required to have GM create the key vault
                    create_new_keyvault         = optional(bool, false)
                    name                        = optional(string, "")
                    private_endpoint_subnet_id  = optional(string, "")
                    private_dns_zone_id         = optional(string, "")  
                    allow_public_network_access = optional(bool, false)
                    allowed_public_ips          = optional(list(string), [])   
                    allowed_subnet_ids          = optional(list(string), [])  
                    
                    #These set of varibles required if using existing Bring Your Own key vault
                    id                         = optional(string, "")
                    enable_rbac_authorization  = optional(bool, false)
                    cmk_key_name               = optional(string, "")
               })
    

    validation {
     condition     = var.cmk_keyvault.create_new_keyvault ? length(var.cmk_keyvault.name) > 0 : true
     error_message = "Invalid CMK Key Vault settings. Set 'name', 'private_endpoint_subnet_id' (optional) and 'private_dns_zone_id' (for Cigna tenant) attributes to create a new key vault."
    }  

   validation {
     condition     = var.cmk_keyvault.create_new_keyvault == false ? length(var.cmk_keyvault.id) > 0 : true
     error_message = "Invalid CMK Key Vault settings. Set 'id', 'rbac_permission_model_enabled' and cmk_key_name attributes to use an existing key vault"
    } 

   validation {
     condition     = var.cmk_keyvault.create_new_keyvault == false ? length(var.cmk_keyvault.cmk_key_name) > 0 : true
     error_message = "Invalid CMK Key Vault settings. Set 'id', 'rbac_permission_model_enabled' and cmk_key_name attributes to use an existing key vault"
    } 

}

variable user_assigned_identity_ids {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Storage Account."
  type        = list(string)
  default     = []
}

##### Private Endpoint variables ###
variable "private_endpoints" {
    description = "List of private endpoint subnames to create"
    type        = list(string)
    default     = []
}

variable "pe_subnet_id" {
  description = "Subnet Id used for Private Endpoint IPs."
  type = string
  default = ""
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone Id. For Cigna tenant only."
  type = string
  default = ""
  
}

variable "enable_ccoe_local_testing" {
  description = "To be used by CCOE team for local module testing"
  type        = bool
  default     = false
}

variable "TimerDelay" {
  description = "Timer delay to wait for permission assignments and/or private endpoint DNS entry and approval."
  type        = string
  default     = "2m"
}


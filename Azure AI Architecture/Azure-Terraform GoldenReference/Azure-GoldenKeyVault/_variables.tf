variable "resource_group_name" {
  description = "Resource group for this deployment"
  type        = string
  validation {
    condition     = var.resource_group_name != "" 
    error_message = "Resource group required."
  }
}

variable "name" {
  description = "Name of the Key Vault. Used as a prefix for other resources."
  type        = string
}

variable "location" {
  description = "Location to deploy Key Vault in."
  type        = string 
}

variable "required_tags" {
  description = "Required tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+v2.0)."
  type = object({
    AssetOwner       = string
    CostCenter       = string
    ServiceNowAS     = string
    ServiceNowBA     = string
    SecurityReviewID = string
  })
  validation {
    condition     =  var.required_tags.AssetOwner != "" && var.required_tags.CostCenter != "" && var.required_tags.ServiceNowAS != "" && var.required_tags.ServiceNowBA != "" && var.required_tags.SecurityReviewID != ""
    error_message = "Defining all tags is required for this resource (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+v2.0)."
  }
}

variable "optional_tags" {
  description = "Optional tags to include with required tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)."
  type        = map(string)
  default     = {}
}

variable "afdiags" {
  type        = bool
  description = "Set to true if diagnostics should be sent to SEIM"
  default     = false
}
variable "keyvault_diagnostics_settings" {
    description     = "List of diagnostic settings"
    type = list(object({
        name                                 = string,
        log_analytics_workspace_id           = optional(string, null),
        storage_id                           = optional(string, null),
        eventhub_authorization_rule_id       = optional(string, null),
        eventhub_name                        = optional(string, null)
        include_diagnostic_log_categories    = bool,
        include_diagnostic_metric_categories = bool  
    }))

    validation {
    condition     = length(var.keyvault_diagnostics_settings) > 0 ? true : false
    error_message = "At least one keyvault diagnostic setting is required."
    }
    
    validation {
    condition     = anytrue([for lc in var.keyvault_diagnostics_settings : lc.include_diagnostic_log_categories])
    error_message = "At least one log category must be enabled in keyvault diagnostic settings."
    }

}

variable "private_endpoint_subnet_id" {
  type = string
  description = "ID of subnet in which to create private endpoint."
  default = ""
  validation {
    condition     = var.private_endpoint_subnet_id == null ? false : true
    error_message = "Variable private_endpoint_subnet_id cannot be null. Empty string is allowed."
    }
}

variable "private_dns_zone_id" {
  type = string
  description = "ID of private DNS zone for private endpoint, if private DNS zone used."
  default = ""
  validation {
    condition     = var.private_dns_zone_id == null ? false : true
    error_message = "Variable private_dns_zone_id cannot be null. Empty string is allowed."
    }

}

variable "enabled_for_deployment" {
  type        = bool
  description = "Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the Key Vault."
  default     = false
}

variable "enable_purge_protection" {
  type        = bool
  description = "Boolean flag to enable purge protection."
  default     = true
}

variable "soft_delete_retention" {
  type        = number
  description = "Number of days that the Key Vault is held in a suspended state before being wiped. May need to be set higher for use with some services such as Event Hubs."
  default     = 7
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
  default     = false
}

variable "enabled_for_template_deployment" {
  type        = bool
  description = "Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the Key Vault."
  default     = false
}

variable "initial_access_assignments" {
  type = set(object({
    principal_id   = string
    roles          = list(string)
    principal_type = string
  }))
  description = "Permissions (RBAC Roles or equivilant Access Policies) to apply when Key Vault is created."
  default     = []
}

variable "public_network_access" {
  type        = bool
  description = "Override use only - Allow public network access (Public IP) to this Key Vault."
  default     = false
}

variable "allowed_ip_rules" {
  type        = list(string)
  description = "IP Addresses allowed to access the Key Vault. This can be useful for Key Vaults used to encrypt terraform state where terraform is run from on premise."
  default = []
  validation {
    condition  = length(var.allowed_ip_rules) > 0 ? alltrue([ for ip in var.allowed_ip_rules : !strcontains(ip, "0.0.0.0") ] ): true                                                   
    error_message = "IP 0.0.0.0 is not allowed. Reference variable: allowed_ip_rules."
   }
}

variable "include_ado_cidrs" {
  type        = bool
  description = "Include ADO CIDRs when configuring ADO pipeline variable groups that require key vault access. (https://learn.microsoft.com/en-us/azure/devops/pipelines/process/set-secret-variables?view=azure-devops&tabs=yaml%2Cbash#link-secrets-from-an-azure-key-vault)"
  default     = false
}

variable "virtual_network_subnet_ids" {
  type        = list(string)
  description = "List of subnet ids allowed to connect securely and directly to Key Vault using service endpoints."
  default     = []
}

variable "bypass_trusted_services" {
  type        = bool
  description = "Allow Azure trusted services to bypass the firewall."
  default     = false
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Use RBAC authentication for Key Vault."
  default     = true
}

variable "sku_name" {
  type        = string
  description = "Provided as an over-ride feature, in case Key Vaults that require HSM protection are required."
  default     = "standard"
}

variable "tenant_id" {
  type        = string
  description = "ID of tenant Key Vault will use to authenticate requests -- provided as an over-ride in case deployment environment does not properly support client_config data source."
  default     = null
}

variable "keyvault_keys" {
    description = "List of keys to create."
    type        = map(object({
                      key_type = optional(string, "RSA")
                      key_size = optional(number, 4096) 
                      key_opts = list(string)
                     }))
    default     = {}

   validation {
    condition  = length(var.keyvault_keys) > 0 ? alltrue([ for key in var.keyvault_keys : contains(["RSA", "EC"], key.key_type) ] ): true                                                   
    error_message = "One or more Key Types are invalid. Valid Key Types: RSA or EC."
   } 

   validation {
    condition  = length(var.keyvault_keys) > 0 ? alltrue([ for key in var.keyvault_keys : contains([2048, 3072, 4096], key.key_size) ] ): true                                                   
    error_message = "One or more Key Size are invalid. Valid Key Sizes: 2048, 3072 or 4096."
   }      
}

variable "TimerDelay" {
  description = "Timer delay to wait for permission assignments and/or private endpoint DNS entry and approval."
  type        = string
  default     = "2m"
}


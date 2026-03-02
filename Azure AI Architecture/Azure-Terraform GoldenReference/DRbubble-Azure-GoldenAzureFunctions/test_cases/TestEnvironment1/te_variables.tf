#Standard variables that appear in all modules
variable "location" {
  description = "Region to deploy to"
  type        = string
  default     = "EastUS"
}

variable "resource_group_name" {
  description = "Resource group to deploy into"
  type        = string
}

variable "name" {
  description = "Base name of application to create (-plan, -app, etc will be postpended to this name for specifc resource types)"
  type        = string
}

/* Note, "required_tags" and "user_defined_tags" are combined into a single local variable "tags". 
   Reference the local variable when creating resources.                                            */


variable required_tags {
  description = "Tags that are required per the version 2 tagging standards."
  type = object({
    SecurityReviewID = string
    AssetOwner       = string
    ServiceNowBA     = string
    CostCenter       = string
    ServiceNowAS     = string
  })
  validation {
    condition = var.required_tags.SecurityReviewID != "" && var.required_tags.AssetOwner != "" && var.required_tags.ServiceNowBA != "" && var.required_tags.CostCenter != "" && var.required_tags.ServiceNowAS != ""
    error_message = "Defining all tags is required for this resource (reference https://confluence.sys.cigna.com/pages/viewpage.action?spaceKey=CLOUD&title=Cloud+Tagging+Requirements+v2.0)."
  }
}

variable required_data_tags {
  description = "Tags that are required for data at rest per the version 2 tagging standards."
  type = object({
    DataSubjectArea        = string
    ComplianceDataCategory = string
    DataClassification     = string
    BusinessEntity         = string
    LineOfBusiness         = string
  })
  validation {
    condition = var.required_tags.DataSubjectArea != "" && var.required_tags.ComplianceDataCategory != "" && var.required_tags.DataClassification != "" && var.required_tags.BusinessEntity != "" && var.required_tags.LineOfBusiness != ""
    error_message = "Defining all tags is required for this resource (reference https://confluence.sys.cigna.com/pages/viewpage.action?spaceKey=CLOUD&title=Cloud+Tagging+Requirements+v2.0)."
  }
}

variable optional_tags {
  description = "Map of optional user defined tags for Azure resource."
  type        = map(string)
  default     = {}
}

variable optional_data_tags {
  description = "Map of optional user defined data tags for Azure resources."
  type        = map(string)
  default     = {}
}

#Add additional variables as needed

variable private_endpoint_subnet_ids {
  type        = list(string)
  description = "Ids of the Private Endpoint subnet to use"
}

variable vnet_names {
  type        = list(string)
  description = "Names of the Virtual Network to use"
}

variable enabled_for_deployment {
  type        = bool
  description = "Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault."
  default     = false
}

variable soft_delete_retention {
  type        = number
  description = "Number of days that the key vault is held in a suspended state before being wiped. May need to be set higher for use with some services such as Event Hubs."
  default     = 7
}

variable enabled_for_disk_encryption {
  type        = bool
  description = "Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
  default     = false
}

variable enabled_for_template_deployment {
  type        = bool
  description = "Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault."
  default     = false
}

variable allowed_ip_rules {
  type        = list(string)
  description = "IP Addresses allowed to access the Key Vault. This can be useful for key vaults used to encrypt terraform state where terraform is run from on premise."
  default     = []
}

variable monitor_log_storage_account_id {
  type        = string
  description = "The storage account id to store audit logs/all metrics in. If not provided, logs/metrics will not be captured."
  default     = null
}

variable log_retention {
  type        = number
  description = "Number of days to persist logs for if a storage account has been provided for them."
  default     = 91
}

variable metric_retention {
  type        = number
  description = "Number of days to persist metrics for if a storage account has been provided for them."
  default     = 91
}

variable rsa_keys {
  type = map(object({
    key_usage = list(string)
  }))
  description = "An optional mapping of key names to key configurations for RSA keys. Currently only supports RSA key types with a key size of 4096."
  default     = {}
}

variable disk_encryption_sets {
  type = map(object({
    #name of the key in key vault
    encryption_key = string
  }))
  description = "An optional mapping of disk_encryption_set names to disk_encryption_set configurations."
  default     = {}
}

variable "resource_group_name" {
  description = "Resource group for this deployment"
  type        = string
}

variable "name" {
  description = "Name of the Key Vault. Used as a prefix for other resources."
  type        = string
}

variable "location" {
  description = "Location to deploy Key Vault in."
  default     = "EastUS"
}

variable "required_tags" {
  description = ""
  type = object({
    SecurityReviewID = string
    AssetOwner       = string
    ServiceNowBA     = string
    CostCenter       = string
    ServiceNowAS     = string
  })
  validation {
    condition     = var.required_tags.SecurityReviewID != "" && var.required_tags.AssetOwner != "" && var.required_tags.ServiceNowBA != "" && var.required_tags.CostCenter != "" && var.required_tags.ServiceNowAS != ""
    error_message = "Defining all tags is required for this resource (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+v2.0)."
  }
}

variable "optional_tags" {
  description = "Map of user defined tags for Azure resource."
  type        = map(string)
  default     = {}
}

variable "afdiags" {
  type        = bool
  description = "Set to false if no diagnostics should be sent to Alarm Funnel"
  default     = true
}

variable "service_endpoints" {
  type = map(object({
    vNet_name           = string
    subnet_name         = string
    resource_group_name = string
  }))
  description = "List of subnets allowed to connect securely and directly to Key Vault using service endpoints"
  default     = {}
}

variable "private_endpoints" {
  type = map(object({
    vNet_name           = string
    subnet_name         = string
    resource_group_name = string
  }))
  description = "List of subnets to create Private Endpoint in"
  default     = {}
}

variable "enabled_for_deployment" {
  type        = bool
  description = "Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the Key Vault."
  default     = false
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
    principal_id = string
    roles        = list(string)
  }))
  description = "..."
  # default = null
  default = []
}

variable "allowed_ip_rules" {
  type        = list(string)
  description = "IP Addresses allowed to access the Key Vault. This can be useful for Key Vaults used to encrypt terraform state where terraform is run from on premise."
  default     = []
}

variable "public_network_access" {
  type        = bool
  description = "Allow public network access (Public IP) to this Key Vault."
  default     = false
}

variable "bypass_trusted_services" {
  type        = bool
  description = "Allow Azure trusted services to bypass the firewall."
  default     = false
}

variable "monitor_log_storage_account_id" {
  type        = string
  description = "The storage account id to store audit logs/all metrics in. If not provided, logs/metrics will not be captured."
  default     = null
}

variable "log_retention" {
  type        = number
  description = "Number of days to persist logs for if a storage account has been provided for them."
  default     = 91
}

variable "metric_retention" {
  type        = number
  description = "Number of days to persist metrics for if a storage account has been provided for them."
  default     = 91
}

variable "rsa_keys" {
  type = map(object({
    key_usage = list(string)
  }))
  description = "An optional mapping of key names to key configurations for RSA keys. Currently only supports RSA key types with a key size of 4096."
  default     = {}
}

variable "disk_encryption_sets" {
  type = map(object({
    #name of the key in Key Vault
    encryption_key = string
  }))
  description = "An optional mapping of disk_encryption_set names to disk_encryption_set configurations."
  default     = {}
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Use RBAC authentication for Key Vault -- this is the preferred method. Should only be set to false when required for development."
  default     = true
}

variable "sku_name" {
  type        = string
  description = "Provided as an over-ride feature, in case Key Vaults that require HSM protection are required."
  default     = "standard"
}

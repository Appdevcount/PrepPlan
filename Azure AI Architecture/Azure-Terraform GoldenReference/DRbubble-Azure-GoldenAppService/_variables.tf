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

variable "required_tags" {
  description = "Required Cigna tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)"
  type = object({
    AssetOwner       = string
    CostCenter       = string
    ServiceNowBA     = string
    ServiceNowAS     = string
    SecurityReviewID = string
  })
  validation {
    condition     = var.required_tags.AssetOwner != "" && var.required_tags.CostCenter != "" && var.required_tags.ServiceNowBA != "" && var.required_tags.ServiceNowAS != "" && var.required_tags.SecurityReviewID != ""
    error_message = "Defining all tags is required for this resource (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)."
  }
}
variable "user_defined_tags" {
  description = "Optional Cigna standard tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)"
  type        = map(string)
  default     = {}
}

#Add additional variables as needed

variable "pe_virtual_network_name" {
  type        = string
  description = "Name of vNet where private endpoint should be deployed"
}

variable "pe_subnet_name" {
  type        = string
  description = "Name of subnet private endpoint should be deployed into"
}

variable "sku" {
  type        = string
  description = "SKU tier and size (S1, S2, S3, P1V2, P2V2, P3V2, P1V3, P2V3, or P3V3) for service plan"
}

variable "kind" {
  type        = string
  description = "OS for App Service Plan (Linux or Windows)"
  default     = "Linux"
}

variable "app_service_environment_id" {
  type        = string
  description = "ID of App Service Environment to run this app in - if set plan tier must be premium"
  default     = null
}

variable "app_settings" {
  type        = map(string)
  description = "KEY = VALUE pairs of app settings (e.g {WEBSITE_PRIVATE_EXTENSIONS = 0, WEBSITE_SLOT_MAX_NUMBER_OF_TIMEOUTS = 4})"
  default     = {}
}

variable "client_affinity_enabled" {
  type        = bool
  description = "Set to true if cookie based affinity should be enabled"
  default     = false
}

variable "client_cert_enabled" {
  type        = bool
  description = "Does this application require client certification?"
  default     = false
}

variable "connection_strings" {
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  description = "main connection strings var"
  default     = []
}

variable "auth_settings" {
  type = object({
    enabled           = bool
    client_id         = string
    allowed_audiences = list(string)
  })
  description = "If authentication is required, provide client_id and issuer from app registration"
  default = {
    enabled           = false
    client_id         = ""
    allowed_audiences = []
  }
}

variable "site_config" {
  type        = map(any)
  description = "See site_config block.md"
  default     = null
}

variable "ip_restriction" {
  type = list(object({
    type     = string
    name     = string
    priority = number
    action   = string
    address  = string
  }))
  description = "Network (firewall) rules. Type should be ip_address, service_tag, or subnet_id depending on the type of address provided."
  default = [{
    type     = "ip_address"
    name     = "Deny All"
    priority = 200
    action   = "Deny"
    address  = "0.0.0.0/0"
  }]
}

variable "scm_ip_restriction" {
  type = list(object({
    type     = string
    name     = string
    priority = number
    action   = string
    address  = string
  }))
  description = "Network (firewall) rules. Type should be ip_address, service_tag, or subnet_id depending on the type of address provided."
  default = [{
    type     = "ip_address"
    name     = "Deny All"
    priority = 200
    action   = "Deny"
    address  = "0.0.0.0/0"
  }]
}

variable "cors_allowed_origins" {
  type        = list(string)
  description = "List of allowed CORS origins"
  default     = []
}

variable "storage_account" {
  type = object({
    name         = string
    account_name = string
    share_name   = string
    access_key   = string
  })
  default = null
}

variable "logs" {
  type = object({
    detailed_error_messages_enabled = bool
    failed_request_tracing_enabled  = bool
    level                           = string
    sas_url                         = string
    retention_in_days               = string
  })
  description = "Configuration of log settings"
  default     = null
  sensitive   = true
}

/*
A storage_account block supports the following:
name - (Required) The name of the storage account identifier.
type - (Required) The type of storage. Possible values are AzureBlob and AzureFiles.
account_name - (Required) The name of the storage account.
share_name - (Required) The name of the file share (container name, for Blob storage).
access_key - (Required) The access key for the storage account.
mount_path - (Optional) The path to mount the storage within the site's runtime environment.

*/

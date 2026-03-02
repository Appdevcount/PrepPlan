variable "location" {
  description = "Region to deploy to"
  type        = string
  default     = "EastUS"
}

variable "resource_group_name" {
  description = "Resource group to deploy in"
  type        = string
}

variable "name" {
  description = "Name of namespace to create"
  type        = string
}

variable "pe_subnet_id" {
  description = "ID of subnet where private endpoint should attach"
  type        = string
  default     = null
}

variable "pe_resource_group_name" {
  description = "Resource group where PE shold be created, if different than resource group for namespace"
  type        = string
  default     = null
}

variable "pe_dr_resource_group_name" {
  description = "Resource group where DR PE shold be created, if different than resource group for namespace"
  type        = string
  default     = null
}

variable "dedicated_cluster_id" {
  description = "If using a dedicated Event Hub cluster, ID of that cluster"
  type        = string
  default     = null
}

variable "dr_dedicated_cluster_id" {
  description = "If using a dedicated DR Event Hub cluster, ID of that cluster"
  type        = string
  default     = null
}

variable "sku" {
  #Basic should not be used in production, but is included as switch for this module to support dev or test scenarios
  description = "SKU (Account Tier) for Event Hub Namespace -- Standard or Basic (not recommended for production)."
  type        = string
  default     = "Standard"
  validation {
    condition     = var.sku == "Basic" || var.sku == "Standard"
    error_message = "Event Hub Namespace SKU (Tier) must be Standard, or Basic."
  }
}

variable "capacity" {
  description = "Initial TU capacity (does not apply to Dedicated clusters) -- must be 1-20"
  type        = number
  default     = 1
  validation {
    condition     = var.capacity <= 20
    error_message = "Namespace TU must be between 1 and 20 at creation -- if 40 is needed, contact Microsoft Support to have TU upgraded."
  }
}

variable "namespace_shared_access_policies" {
  description = "Shared access policies to create for the Event Hub namespace -- only create if the application cannot support AAD integrated access."
  type = map(object({
    send   = bool
    listen = bool
  }))
  default = null
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access the Event Hub namespace"
  type        = list(string)
  default     = []
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP subnets for Event Hub namespace"
  type        = list(string)
  default     = []
}

variable "event_hubs" {
  description = "Describes the event hubs to create in the namespace (See README.MD for full description and usage)"
  type = map(object({
    partition_count   = number
    message_retention = number
    consumer_groups   = list(string)
    access_policies = map(object({
      send   = bool
      listen = bool
    }))

  }))
}

variable "dr_location" {
  description = "Region for Geo-DR -- if set and SKU is standard, Geo-DR will be enabled"
  type        = string
  default     = null
}

variable "pe_dr_subnet_id" {
  description = "ID of subnet where private endpoint should attach"
  type        = string
  default     = null
}

variable "logging_enabled" {
  description = "Set to true if additional logging should be enabled - a log destination must be provided if this is not set to false"
  type        = bool
  default     = false
}

variable "log_storage_account_id" {
  description = "ID of Storage Account to use for diagnostic data destination"
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "ID of Log Analytics Workspace for diagnostic data destination"
  type        = string
  default     = null
}

variable "log_eventhub_name" {
  description = "Name of Event Hub to stream diagnostic data -- leave null to accept default of creating an event hub for each diagnostic category"
  type        = string
  default     = null
}

variable "log_eventhub_namespace_authorization_rule_id" {
  description = "Namespace rule to use for streaming diagnostic data to Event Hub as destination"
  type        = string
  default     = null
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

variable "optional_tags" {
  description = "Optional Cigna standard tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements)"
  type        = map(string)
  default     = {}
}

#Override variables -- these should be left as default, but are provided in case an unanticipated use case dictates over-riding the selected default

variable "private_endpoints" {
  #Private endpoints are typically required, but this over-ride is provided for corner cases that do not need them
  description = "Set to false if private endpoints should not be created"
  type        = bool
  default     = true
}

variable "zone_redundant" {
  #Zone redundancy raises applicatoin resiliancy, with no added cost.
  description = "Enable zone redundancy (applies to Standard tier namespaces only)"
  type        = bool
  default     = true
}

variable "auto_inflate_enabled" {
  #Auto inflate helps avoid performance issues if workload needs change, or where underestimated. Application should be monitored to
  #avoid potential cost over-runs created by auto-inflation that was unexpected / out of design specifications. Manual deflation is required
  #if workload needs decrease.
  description = "Allow TU autoinflate if set to true"
  type        = bool
  default     = true
}

variable "maximum_throughput_units" {
  #Typically should be set to max in production to avoid potential performance issues. Application should be monitored to
  #avoid potential cost over-runs created by auto-inflation that was unexpected / out of design specifications.
  description = "Maximum TUs namespace can inflact to, must be 1-20"
  type        = number
  default     = 20
  validation {
    condition     = var.maximum_throughput_units <= 20
    error_message = "Maximum TU must be between 1 and 20 at creation -- if 40 is needed, contact Microsoft Support to have TU upgraded."
  }
}

variable "trusted_service_access_enabled" {
  #Event Hubs will not work properly if it cannot access other Microsoft services it relies on
  description = "Enable trusted Microsoft services to bypass firewall rules (e.g. allow these services)."
  default     = true
}

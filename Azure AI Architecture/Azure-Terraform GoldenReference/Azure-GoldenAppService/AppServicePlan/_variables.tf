variable "name" {
  description = "Required: Name of App Service Plan"
  type        = string
}

variable "location" {
  description = "Required: Region to deploy to"
  type        = string
  default     = "EastUS2"
}

variable "resource_group_name" {
  description = "Required: Resource group to deploy into"
  type        = string
}

variable "os_type" {
  type        = string
  description = "Required: OS for App Service Plan (Linux, Windows, WindowsContainer)"
}

variable "sku_name" {
  type        = string
  description = "Required: SKU (B1, B2, B3, S1, S2, S3, P1V2, P2V2, P3V2, P1V3, P2V3, or P3V3) for service plan. See link for full possible values: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan"
  default     = "B1"
}

variable "maximum_elastic_worker_count" {
  type        = number
  description = "Optional: The maximum number of workers to use in an Elastic SKU Plan. Cannot be set unless using an Elastic SKU."
  default     = null
}

variable "worker_count" {
  type        = number
  description = "Optional: The number of Workers (instances) to be allocated."
  default     = 1
}

variable "per_site_scaling_enabled" {
  type        = bool
  description = "Optional: Should Per Site Scaling be enabled."
  default     = false
}

variable "zone_balancing_enabled" {
  type        = bool
  description = "Optional: Should the Service Plan balance across Availability Zones in the region. Changing this forces a new resource to be created."
  default     = false
}

variable "app_service_environment_id" {
  type        = string
  description = "Optional: ID of App Service Environment to run this app in - if set plan tier must be isolated"
  default     = null
}

/* Note, "required_tags" and "user_defined_tags" are combined into a single local variable "tags". 
   Reference the local variable when creating resources.                                            */
variable "required_tags" {
  description = "Required: Cigna tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)"
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
  description = "Optional: Cigna standard tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)"
  type        = map(string)
  default     = {}
}
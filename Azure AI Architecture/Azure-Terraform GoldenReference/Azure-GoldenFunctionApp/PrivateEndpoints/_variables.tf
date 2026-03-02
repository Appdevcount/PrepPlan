

variable "location" {
  description = "Required: The Azure Region where the Linux Function App should exist. Changing this forces a new Linux Function App to be created."
  type        = string
}

variable "resource_group_name" {
  description = "Required: Resource group to deploy into"
  type        = string
}

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

variable "private_endpoints" {
  description = "List of private endpoints to create"
  type = object({
    private_connection_resource_id = string,
    endpoints = list(object({
      private_endpoint_name      = string,
      subresource_name           = string,
      private_endpoint_subnet_id = string,
      private_dns_zone_name      = optional(string, ""),
      private_dns_zone_id        = optional(string, "")
    }))

  })

  validation {
    condition     = alltrue([for pe in var.private_endpoints.endpoints : (length(pe.private_dns_zone_id) > 0 ? length(pe.private_dns_zone_name) > 0 : true)])
    error_message = "One or more private endpoint settings has a value for property private_dns_zone_id but no value for property private_dns_zone_name."
  }
}
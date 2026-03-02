variable "subscription_id" {}
variable "environment" {
  description = "Optional: Environment to deploy to."
  type        = string
}

variable "location" {
  description = "Required: Region to deploy to."
  type        = string
  default     = "EastU2"
}

variable "resource_group_name" {
  description = "Required: Resource group to deploy into."
  type        = string
}

variable "app_service_plan_name" {
  description = "Required: Base name of application to create (-plan, -app, etc will be postpended to this name for specifc resource types)"
  type        = string
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

variable "sku_name" {
  type        = string
  description = "Required: SKU (B1, B2, B3, S1, S2, S3, P1V2, P2V2, P3V2, P1V3, P2V3, or P3V3) for service plan. See link for full possible values: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan"
  default     = "B1"
}

variable "os_type" {
  type        = string
  description = "Required: OS for App Service Plan (Linux, Windows, WindowsContainer)"
  default     = "Windows"
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

variable "site_config" {
  type        = map(any)
  description = "See site_config block.md"
  default     = null
}

variable "virtualnetworksubnetid" {
  type = string
  default = ""
  
}

variable "ip_restriction" {
  type = list(object({
    name                      = string #The name which should be used for this ip_restriction.
    priority                  = number #The priority value of this ip_restriction. Defaults to 65000.
    action                    = string #The action to take. Possible values are Allow or Deny.
    ip_address                = optional(string, null) #The CIDR notation of the IP or IP Range to match. For example: 10.0.0.0/24 or 192.168.10.1/32
    virtual_network_subnet_id = optional(string, null) #The Virtual Network Subnet ID used for this IP Restriction.
    service_tag               = optional(string, null) #The Service Tag used for this IP Restriction.
   # headers                   = optional(list(string), null) #A headers block. See terraform documentation.

    headers                   = optional(list(object({
                                              x_azure_fdid      = optional(list(string),[])
                                              x_fd_health_probe = optional(list(string),[])   
                                              x_forwarded_for   = optional(list(string),[])
                                              x_forwarded_host  = optional(list(string),[])    
                                              })), [])

  }))
  description = "Network (firewall) rules. Type should be ip_address, service_tag, or subnet_id depending on the type of address provided."
}


variable "scm_ip_restriction" {
  type = list(object({
    name                      = string #The name which should be used for this ip_restriction.
    priority                  = number #The priority value of this ip_restriction. Defaults to 65000.
    action                    = string #The action to take. Possible values are Allow or Deny.
    ip_address                = optional(string, null) #The CIDR notation of the IP or IP Range to match. For example: 10.0.0.0/24 or 192.168.10.1/32
    virtual_network_subnet_id = optional(string, null) #The Virtual Network Subnet ID used for this IP Restriction.
    service_tag               = optional(string, null) #The Service Tag used for this IP Restriction.
   # headers                   = optional(list(string), null) #A headers block. See terraform documentation.

    headers                   = optional(list(object({
                                              x_azure_fdid      = optional(list(string),[])
                                              x_fd_health_probe = optional(list(string),[])   
                                              x_forwarded_for   = optional(list(string),[])
                                              x_forwarded_host  = optional(list(string),[])    
                                              })), [])

  }))
  description = "Network (firewall) rules. Type should be ip_address, service_tag, or subnet_id depending on the type of address provided."
}

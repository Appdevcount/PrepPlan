
variable "name" {
  description = "Required: Base name of application to create (-plan, -app, etc will be postpended to this name for specifc resource types)"
  type        = string
}

variable "location" {
  description = "Required: The Azure Region where the Linux Function App should exist. Changing this forces a new Linux Function App to be created."
  type        = string
}

variable "resource_group_name" {
  description = "Required: Resource group to deploy into"
  type        = string
}

variable identity_type {
  description = "Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned (to enable both)."
  type        = string
  default     = "SystemAssigned"

    validation {
    condition     =  var.identity_type == "SystemAssigned" || var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned"
    error_message = "Identity Type must be either SystemAssigned or UserAssigned or 'SystemAssigned, UserAssigned'"
  }  
}

variable user_assigned_identity_ids {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Storage Account."
  type        = list(string)
  default     = []
}

variable "use_32_bit_worker" {
  type = bool
  description = "Is the Windows Function App using a 32-bit worker process?"
  default = false  
}

variable "include_app_service_plan" {
  type = bool
  description = "Module will create an App Service Plan"
  default = false
}

variable "include_app_insights" {
  type = bool
  description = "Module will create an Log Analytics Workspace and App Insights"
  default = false
}

variable "include_alerts" {
  type = bool
  description = "Module will create FMEA compliant alerts"
  default = false
}

variable "app_service_plan_name" {
  type        = string
  description = "Name of App Service Plan"
  default     = ""
}

/* variable "os_type" {
  type        = string
  description = "Required: OS for App Service Plan (Linux, Windows, WindowsContainer)"
  default     = "Linux"
} */

variable "service_plan_id" {
  type        = string
  description = "Required: The ID of the App Service Plan within which to create this Function App."
  default     = ""
}

variable "app_service_plan_sku_name" {
  type        = string
  description = "Required: SKU (B1, B2, B3, S1, S2, S3, P1V2, P2V2, P3V2, P1V3, P2V3, or P3V3) for service plan. See link for full possible values: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan"
  default = "B1"
}

variable "plan_maximum_elastic_worker_count" {
  type        = number
  description = "The maximum number of workers to use in an Elastic SKU Plan. Cannot be set unless using an Elastic SKU."
  default = null
}

variable "plan_worker_count" {
  type        = number
  description = "The number of Workers (instances) to be allocated at Plan level."
  default = "1"
}


variable "per_site_scaling_enabled" {
  type        = bool
  description = "Should Per Site Scaling be enabled. Defaults to false."
  default     = false
}

variable "zone_balancing_enabled" {
  type        = bool
  description = "Should the Service Plan balance across Availability Zones in the region. Changing this forces a new resource to be created."
  default     = false
}

#App Site Config
variable "app_worker_count" {
  type        = number
  description = "The number of Workers for this Windows Function App."
  default     = null
}

variable "app_scale_limit" {
  type        = number
  description = "The number of workers this function app can scale out to. Only applicable to apps on the Consumption and Premium plan."
  default     = null
}

variable "elastic_instance_minimum" {
  type        = number
  description = "The number of minimum instances for this Windows Function App."
  default     = null
}

variable "pre_warmed_instance_count" {
  type        = number
  description = "The number of pre-warmed instances for this Windows Function App."
  default     = null
}
variable "runtime_scale_monitoring_enabled" {
  type        = bool
  description = "Is Scale Monitoring of the Functions Runtime enabled?"
  default     = false
}


#eviCore will not be using ASE. Cigna?
variable "app_service_environment_id" {
  type        = string
  description = "The ID of the App Service Environment to create this Service Plan in."
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
    P2P              = string
  })
  validation {
    condition     = var.required_tags.AssetOwner != "" && var.required_tags.CostCenter != "" && var.required_tags.ServiceNowBA != "" && var.required_tags.ServiceNowAS != "" && var.required_tags.SecurityReviewID != "" && var.required_tags.P2P != ""
    error_message = "Defining all tags is required for this resource (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)."
  }
}
variable "optional_tags" {
  description = "Optional: Cigna standard tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)"
  type        = map(string)
  default     = {}
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

/* variable "site_config" {
  type        = map(any)
  description = "See site_config block.md"
  default     = null
} */
variable "always_on" {
  type        = bool
  description = "Optional: If this Linux Web App is Always On enabled. Defaults to false"
  default     = false
  
}
variable "ftps_state" {
  type = string
  description = "Optional: State of FTP / FTPS service for this function app. Defaults to Disabled. Possible values include: FtpsOnly and Disabled. "
  default = "Disabled"

  #Need Validation for allowed values
}
variable "allowed_origins" {
  type = list(string)
  description = "Optional: Specifies a list of origins that should be allowed to make cross-origin calls."
  default = []
}
variable "support_credentials" {
  type = bool
  description = "Optional: Are credentials allowed in CORS requests."
  default = false
}

variable "storage_account_name" {
  type        = string
  description = "Optional: The backend storage account name which will be used by this Function App."
  default     = null
}
variable "storage_account_backup_container_name" {
  type        = string
  description = "Optional: The backend storage account name which will be used by this Function App."
  default     = null
}
variable "storage_account_backup_container_sas" {
  type        = string
  description = "Optional: The backend storage account name which will be used by this Function App."
  default     = null
}

/*NOTE:
One of storage_account_access_key or storage_uses_managed_identity must be specified when using storage_account_name.
*/
variable "storage_account_access_key" {
  type        = string
  description = "Optional: The access key which will be used to access the backend storage account for the Function App. Conflicts with storage_uses_managed_identity."
  default     = null
}
variable "storage_uses_managed_identity" {
  type        = bool
  description = "Optional: Should the Function App use Managed Identity to access the storage account. Conflicts with storage_account_access_key."
  default     = false
}
variable "storage_account_id" {
  type        = string
  description = "Optional: Storage Account Id if Function App uses Managed Identity to access the storage account."
  default     = ""
}

variable "client_certificate_enabled" {
  type = bool
  default = false
}
variable "client_certificate_mode" {
  type = string
  default = "Optional"
}
variable "builtin_logging_enabled" {
  type    = bool
  default = true
}

/*
NOTE on regional virtual network integration:
The AzureRM Terraform provider provides regional virtual network integration via the standalone 
resource app_service_virtual_network_swift_connection and in-line within this resource using the 
virtual_network_subnet_id property. You cannot use both methods simultaneously. 
If the virtual network is set via the resource app_service_virtual_network_swift_connection then 
ignore_changes should be used in the function app configuration.

Note:
Assigning the virtual_network_subnet_id property requires RBAC permissions on the subnet
*/

variable "virtual_network_subnet_id" {
  type = string
  description = "Optional: The subnet id which will be used by this Function App for regional virtual network integration."
  default = ""
  #Need validation, null not accepted value
}

variable "sticky_settings_app_setting_names" {
  type = list(string)
  description = "Optional: A list of app_setting names that the Linux Function App will not swap between Slots when a swap operation is triggered."
  default = null
}
variable "sticky_settings_connection_string_names" {
  type = list(string)
  description = "Optional: A list of connection_string names that the Linux Function App will not swap between Slots when a swap operation is triggered."
  default = null
}

variable "appinsights_connection_string" {
  type = string
  description = "The Connection String for linking the Windows Function App to Application Insights."
  default = ""
  
}
variable "application_insights_key" {
  type = string
  description = "The Instrumentation Key for connecting the Windows Function App to Application Insights."
  default = ""
  
}

variable "private_endpoint_subnet_id" {
  type = string
  default = ""
}

#NOTE:
#One and only one of ip_address, service_tag or virtual_network_subnet_id must be specified.
variable "ip_restriction" {
  type = list(object({
    name                      = string #The name which should be used for this ip_restriction.
    priority                  = number #The priority value of this ip_restriction. Defaults to 65000.
    action                    = string #The action to take. Possible values are Allow or Deny.
    ip_address                = optional(string, null) #The CIDR notation of the IP or IP Range to match. For example: 10.0.0.0/24 or 192.168.10.1/32
    virtual_network_subnet_id = optional(string, null) #The Virtual Network Subnet ID used for this IP Restriction.
    service_tag               = optional(string, null) #The Service Tag used for this IP Restriction.
    headers                   = optional(list(object({
                                                  x_azure_fdid      = optional(list(string),[])
                                                  x_fd_health_probe = optional(list(string),[])   
                                                  x_forwarded_for   = optional(list(string),[])
                                                  x_forwarded_host  = optional(list(string),[])    
                                                 })), [])
    }))
  description = "Network (firewall) rules. Type should be ip_address, service_tag, or subnet_id depending on the type of address provided."
  default = [{
    name     = "Deny All"
    priority = 200
    action   = "Deny"
    ip_address  = "0.0.0.0/0"
  }]
}
variable "ip_restriction_default_action" {
  type        = string
  description = "The Default action for traffic that does not match any ip_restriction rule. possible values include Allow and Deny. Defaults to Deny."
  default     = "Deny"

  #Need validation check
}

#One and only one of ip_address, service_tag or virtual_network_subnet_id must be specified.
variable "scm_ip_restriction" {
  type = list(object({
    name                      = string #The name which should be used for this ip_restriction.
    priority                  = number #The priority value of this ip_restriction. Defaults to 65000.
    action                    = string #The action to take. Possible values are Allow or Deny.
    ip_address                = optional(string, null) #The CIDR notation of the IP or IP Range to match. For example: 10.0.0.0/24 or 192.168.10.1/32
    virtual_network_subnet_id = optional(string, null) #The Virtual Network Subnet ID used for this IP Restriction.
    service_tag               = optional(string, null) #The Service Tag used for this IP Restriction.
    headers                   = optional(list(object({
                                                  x_azure_fdid      = optional(list(string),[])
                                                  x_fd_health_probe = optional(list(string),[])   
                                                  x_forwarded_for   = optional(list(string),[])
                                                  x_forwarded_host  = optional(list(string),[])    
                                                 })), [])
    }))
  description = "Network (firewall) rules. Type should be ip_address, service_tag, or subnet_id depending on the type of address provided."
  default = [{
    name     = "Deny All"
    priority = 200
    action   = "Deny"
    ip_address  = "0.0.0.0/0"
  }]
}
variable "scm_ip_restriction_default_action" {
  type        = string
  description = "The Default action for traffic that does not match any scm_ip_restriction rule. possible values include Allow and Deny. Defaults to Deny."
  default     = "Deny"

  #Need validation check
}

variable "use_dotnet" {
  type = bool
  description = "Use .Net programming language."
  default = true
}
variable "dotnet_version" {
  type = string
  description = "The version of .NET to use. Possible values include v3.0, v4.0 v6.0, v7.0 and v8.0. Defaults to v8.0."
  default = "v8.0"
}
variable "use_dotnet_isolated_runtime" {
  type = bool
  description = "Should the .Net process use an isolated runtime."
  default = true
}

variable "use_java" {
  type = bool
  description = "Use Java programming language."
  default = false
}
variable "java_version" {
  type = string
  description = "The Version of Java to use. Supported versions include 1.8, 11 & 17 (In-Preview)"
  default = "17"
}

variable "use_node" {
  type = bool
  description = "Use Node programming language."
  default = false
}
variable "node_version" {
  type = string
  description = "The version of Node to run. Possible values include ~12, ~14, ~16, ~18 and ~20."
  default = "~20"
}

variable "use_powershell" {
  type = bool
  description = "Use Powershell programming language."
  default = false
}
variable "powershell_core_version" {
  type = string
   description = "The version of PowerShell Core to run. Possible values are 7, and 7.2."
   default = "7.2"
}
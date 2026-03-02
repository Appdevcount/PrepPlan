
variable "name" {
  description = "Required: Base name of application to create (-plan, -app, etc will be postpended to this name for specifc resource types)"
  type        = string
}

variable "location" {
  description = "Required: The Azure Region where the Linux Function App should exist. Changing this forces a new Linux Function App to be created."
  type        = string
}
variable "environment" {
  description = "Environment to deploy to."
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
  description = "Module will create a App Service Plan"
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

variable "include_function_app_slot" {
  type = bool
  description = "Module will create function app slot"
  default = false
}


variable "app_service_plan_name" {
  type        = string
  description = "Name of App Service Plan"
  default     = ""
}


variable "service_plan_id" {
  type        = string
  description = "Required: The ID of the App Service Plan within which to create this Function App."
  default     = ""
}

# App service plan settings
variable "app_service_plan_sku_name" {
  type        = string
  description = "Required: SKU (B1, B2, B3, S1, S2, S3, P1V2, P2V2, P3V2, P1V3, P2V3, or P3V3) for service plan. See link for full possible values: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan"
  default = "B1"
}

#Networking
variable "public_network_access_enabled" {
  type        = bool
  description = " Should public network access be enabled for the Function App."
  default = "false"
}

#Scaling
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

# --
variable "connection_strings" {
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  description = "One or more connection string blocks"
  default     = []
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
  description = "The number of minimum instances for this Windows Function App. Only affects apps on Elastic Premium plans."
  default     = null
}

variable "pre_warmed_instance_count" {
  type        = number
  description = "The number of pre-warmed instances for this Windows Function App. Only affects apps on an Elastic Premium plan."
  default     = null
}

variable "runtime_scale_monitoring_enabled" {
  type        = bool
  description = "Functions runtime scale monitoring can only be enabled for Elastic Premium Function Apps or Workflow Standard Logic Apps and requires a minimum prewarmed instance count of 1."
  default     = false
}

variable "default_documents" {
  type        = list(string)
  description = "Specifies a list of Default Documents for the Windows Function App."
  default     = null
}

variable "health_check_path" {
  type        = string
  description = "The path to be checked for this Windows Function App health."
  default     = null
}

variable "health_check_eviction_time_in_min" {
  type        = number
  description = "The amount of time in minutes that a node can be unhealthy before being removed from the load balancer. Possible values are between 2 and 10. Only valid in conjunction with health_check_path."
  default     = null
}
variable "load_balancing_mode" {
  type        = string
  description = "The Site load balancing mode. Possible values include: WeightedRoundRobin, LeastRequests, LeastResponseTime, WeightedTotalTraffic, RequestHash, PerSiteRoundRobin. Defaults to LeastRequests."
  default     = null
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

variable "always_on" {
  type        = bool
  description = "Optional: When running in a Consumption or Premium Plan, always_on feature should be turned off. Please turn it off before upgrading the service plan from standard to premium."
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
  default = null
}
variable "support_credentials" {
  type = bool
  description = "Optional: Are credentials allowed in CORS requests."
  default = false
}

#Storage Account variables
variable "storage_account_name" {
  type        = string
  description = "Optional: The backend storage account name which will be used by this Function App."
}

variable "storage_account_id" {
  type        = string
  description = "Optional: Storage Account Id if Function App uses Managed Identity to access the storage account."
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
Note:
Assigning the virtual_network_subnet_id property requires RBAC permissions on the subnet
*/

variable "vnet_route_all_enabled" {
  type = bool
  description = "value"
  default = false
  
}
variable "virtual_network_subnet_id" {
  type = string
  description = "Optional: The subnet id which will be used by this Function App for regional virtual network integration."
  default = null
}

variable "functions_extension_version" {
  type = string
  description = "The runtime version associated with the Function App. Defaults to ~4"
  default = null
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
  description = "The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint."
  default = ""
}

variable "private_dns_zone_name" {
  type = string
  description = "Optional: Private DNS Zone Name. For Cigna tenant only."
  default = ""
}

variable "private_dns_zone_id" {
  type = string
  description = "Optional: Private DNS Zone ID. For Cigna tenant only. Example: privatelink.blob.core.windows.net"
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
    default = []
}
variable "ip_restriction_default_action" {
  type        = string
  description = "The Default action for traffic that does not match any ip_restriction rule. possible values include Allow and Deny. Defaults to Deny."
  default     = "Deny"
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
    default = []
}

variable "scm_ip_restriction_default_action" {
  type        = string
  description = "The Default action for traffic that does not match any scm_ip_restriction rule. possible values include Allow and Deny. Defaults to Deny."
  default     = "Deny"
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

variable "function_diagnostics_settings" {
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
    condition     = length(var.function_diagnostics_settings) > 0 ? true : false
    error_message = "At least one function diagnostic setting is required."
    }
}

variable "function_app_slot" {
 description = "Details for creating Function App Slot"
 type = object({
   name                              = string
   service_plan_id                   = optional(string, null)
   app_settings                      = optional(map(string), {})
   private_endpoint_subnet_id        = optional(string, "")
   private_dns_zone_id               = optional(string, "") #For Cigna tenant only
   ip_restriction                    = optional(list(object({
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
                                                })), [])
   scm_ip_restriction                = optional(list(object({
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
                                                })), [])                                               
 })

 default = {
             name = ""
 }
 
}

variable "timeouts" {
  type = object ({
    create = optional(string, null)
    read   = optional(string, null)
    update = optional(string, null)
    delete = optional(string, null)
  })
  description = "Allows you to specify timeouts for certain actions"
  default = {
    create = null
    read   = null
    update = null
    delete = null
  }
}

#Security
variable "auth_settings" {
 description = "Details for auth settings"
 type = object({
   enabled                        = optional(bool, false)
   additional_login_parameters    = optional(map(string), {})
   allowed_external_redirect_urls = optional(list(string), [])
   default_provider               = optional(string, null)
   runtime_version                = optional(string, null)
   token_refresh_extension_hours  = optional(number, 0)
   token_store_enabled            = optional(bool, false)
   unauthenticated_client_action  = optional(string, null)
   active_directory               = optional(object({
                                                      allowed_audiences          = optional(list(string),[])
                                                      client_id                  = string 
                                                      client_secret              = optional(string, null)
                                                      client_secret_setting_name = optional(string, null)
                                                    }))  
   
  })
  default = {
    enabled          = false
    active_directory = {
      client_id = ""
    }
  }
}

#Monitoring alerts
variable "alarm_funnel_resourcegroup_name" {
  type        = string
  description = "Resource group name where alarm funnel action group is located."
  default     = ""
}
variable "alarm_funnel_action_group_name" {
  type        = string
  description = "Alarm Funnel Action Group name."
  default     = ""
}
variable "alert_action_group_email" {
  type        = string
  description = "Email address to send alert in addition to alarm funnel notification."
  default     = ""
}



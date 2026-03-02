
variable "name" {
  description = "Required: Base name of application to create (-plan, -app, etc will be postpended to this name for specifc resource types)"
  type        = string
}

variable "location" {
  description = "Required: The Azure Region where the Linux Web App should exist. Changing this forces a new Linux Web App to be created."
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

variable "identity_type" {
  description = "Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned (to enable both)."
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = var.identity_type == "SystemAssigned" || var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned"
    error_message = "Identity Type must be either SystemAssigned or UserAssigned or 'SystemAssigned, UserAssigned'"
  }
}

variable "user_assigned_identity_ids" {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Storage Account."
  type        = list(string)
  default     = []
}

variable "use_32_bit_worker" {
  type        = bool
  description = "Is the Windows Web App using a 32-bit worker process?"
  default     = false
}

variable "managed_pipeline_mode" {
  type        = string
  description = "Managed pipeline mode. Possible values include: Integrated, Classic."
  default     = "Integrated"
}

#Optional resources to include
variable "include_app_service_plan" {
  type        = bool
  description = "Module will create a App Service Plan"
  default     = false
}

variable "include_app_insights" {
  type        = bool
  description = "Module will create an Log Analytics Workspace and App Insights"
  default     = false
}

variable "include_web_app_slot" {
  type        = bool
  description = "Module will create web app slot"
  default     = false
}


variable "app_service_plan_name" {
  type        = string
  description = "Name of App Service Plan"
  default     = ""
}


variable "service_plan_id" {
  type        = string
  description = "Required: The ID of the App Service Plan within which to create this Web App."
  default     = ""
}

# App service plan settings
variable "app_service_plan_sku_name" {
  type        = string
  description = "Required: SKU (B1, B2, B3, S1, S2, S3, P1V2, P2V2, P3V2, P1V3, P2V3, or P3V3) for service plan. See link for full possible values: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan"
  default     = "B1"
}

#Networking
variable "public_network_access_enabled" {
  type        = bool
  description = " Should public network access be enabled for the Web App."
  default     = "false"
}

#Scaling
variable "plan_maximum_elastic_worker_count" {
  type        = number
  description = "The maximum number of workers to use in an Elastic SKU Plan. Cannot be set unless using an Elastic SKU."
  default     = null
}

variable "plan_worker_count" {
  type        = number
  description = "The number of Workers (instances) to be allocated at Plan level."
  default     = "1"
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

#Deployment
variable "zip_deploy_file" {
  type        = string
  description = "The local path and filename of the Zip packaged application to deploy to this Windows Web App. Using this value requires either WEBSITE_RUN_FROM_PACKAGE=1 or SCM_DO_BUILD_DURING_DEPLOYMENT=true to be set on the App in app_settings."
  default     = null
}

#App Site Config
variable "app_worker_count" {
  type        = number
  description = "The number of Workers for this Windows Web App."
  default     = null
}

variable "app_scale_limit" {
  type        = number
  description = "The number of workers this web app can scale out to. Only applicable to apps on the Consumption and Premium plan."
  default     = null
}

variable "elastic_instance_minimum" {
  type        = number
  description = "The number of minimum instances for this Windows Web App. Only affects apps on Elastic Premium plans."
  default     = null
}

variable "pre_warmed_instance_count" {
  type        = number
  description = "The number of pre-warmed instances for this Windows Web App. Only affects apps on an Elastic Premium plan."
  default     = null
}

variable "runtime_scale_monitoring_enabled" {
  type        = bool
  description = "Web App runtime scale monitoring can only be enabled for Elastic Premium Web Apps or Workflow Standard Logic Apps and requires a minimum prewarmed instance count of 1."
  default     = false
}

variable "default_documents" {
  type        = list(string)
  description = "Specifies a list of Default Documents for the Windows Web App."
  default     = null
}

variable "health_check_path" {
  type        = string
  description = "The path to be checked for this Windows Web App health."
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

variable "storage_account" {
  type = object({
    access_key   = string
    account_name = string
    name         = string
    share_name   = string
    type         = string
    mount_path   = optional(string, null)
  })
  description = "Storage account block."
  default     = null
}

variable "virtual_application" {
  type = list(object({
    physical_path = string
    preload       = string
    virtual_path  = string
    virtual_directory = optional(list(object({
      physical_path = optional(string, null)
      virtual_path  = optional(string, null)
    })), [])
  }))
  description = "Virtual directory block."
  default     = []
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

variable "webdeploy_publish_basic_authentication_enabled" {
  type = bool
  default = false
  description = "Should the default WebDeploy Basic Authentication publishing credentials enabled."
}
variable "ftp_publish_basic_authentication_enabled" {
  type = bool
  default = false
  description = "Should the default FTP Basic Authentication publishing profile be enabled."
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
  description = "Optional:  If this Windows Web App is Always On enabled. Must be explicitly set to false when using Free, F1, D1, or Shared Service Plans."
  default     = false

}

variable "allowed_origins" {
  type        = list(string)
  description = "Optional: Specifies a list of origins that should be allowed to make cross-origin calls."
  default     = null
}
variable "support_credentials" {
  type        = bool
  description = "Optional: Are credentials allowed in CORS requests."
  default     = false
}


variable "client_certificate_enabled" {
  type        = bool
  description = "Should Client Certificates be enabled?"
  default     = false
}
variable "client_certificate_mode" {
  type        = string
  description = "he Client Certificate mode. Possible values are Required, Optional, and OptionalInteractiveUser. This property has no effect when client_cert_enabled is false."
  default     = "Optional"
}

variable "remote_debugging_enabled" {
  type        = bool
  description = "Should Remote Debugging be enabled."
  default     = false
}


/*
Note:
Assigning the virtual_network_subnet_id property requires RBAC permissions on the subnet
*/

variable "vnet_route_all_enabled" {
  type        = bool
  description = "value"
  default     = false

}
variable "virtual_network_subnet_id" {
  type        = string
  description = "Optional: The subnet id which will be used by this Web App for regional virtual network integration."
  default     = null
}

variable "sticky_settings_app_setting_names" {
  type        = list(string)
  description = "Optional: A list of app_setting names that the Linux Web App will not swap between Slots when a swap operation is triggered."
  default     = null
}
variable "sticky_settings_connection_string_names" {
  type        = list(string)
  description = "Optional: A list of connection_string names that the Linux Web App will not swap between Slots when a swap operation is triggered."
  default     = null
}

variable "appinsights_connection_string" {
  type        = string
  description = "The Connection String for linking the Windows Web App to Application Insights."
  default     = ""

}
variable "application_insights_key" {
  type        = string
  description = "The Instrumentation Key for connecting the Windows Web App to Application Insights."
  default     = ""

}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint."
  default     = ""
}

variable "private_dns_zone_name" {
  type        = string
  description = "Optional: Private DNS Zone Name. Example: privatelink.azurewebsites.net"
  default     = ""
}

variable "private_dns_zone_id" {
  type        = string
  description = "Optional: Private DNS Zone ID."
  default     = ""
}

 variable "nonroutable_private_endpoint" {
  description = "Set to True if enabling non-routable Private Endpoints using a non-routable vnet."
  type        = bool
  default     = false
 }

#NOTE:
#One and only one of ip_address, service_tag or virtual_network_subnet_id must be specified.
variable "ip_restriction" {
  type = list(object({
    name                      = string                 #The name which should be used for this ip_restriction.
    priority                  = number                 #The priority value of this ip_restriction. Defaults to 65000.
    action                    = string                 #The action to take. Possible values are Allow or Deny.
    ip_address                = optional(string, null) #The CIDR notation of the IP or IP Range to match. For example: 10.0.0.0/24 or 192.168.10.1/32
    virtual_network_subnet_id = optional(string, null) #The Virtual Network Subnet ID used for this IP Restriction.
    service_tag               = optional(string, null) #The Service Tag used for this IP Restriction.
    headers = optional(list(object({
      x_azure_fdid      = optional(list(string), [])
      x_fd_health_probe = optional(list(string), [])
      x_forwarded_for   = optional(list(string), [])
      x_forwarded_host  = optional(list(string), [])
    })), [])
  }))
  description = "Network (firewall) rules. Type should be ip_address, service_tag, or subnet_id depending on the type of address provided."
  default     = []
}

#One and only one of ip_address, service_tag or virtual_network_subnet_id must be specified.
variable "scm_ip_restriction" {
  type = list(object({
    name                      = string                 #The name which should be used for this ip_restriction.
    priority                  = number                 #The priority value of this ip_restriction. Defaults to 65000.
    action                    = string                 #The action to take. Possible values are Allow or Deny.
    ip_address                = optional(string, null) #The CIDR notation of the IP or IP Range to match. For example: 10.0.0.0/24 or 192.168.10.1/32
    virtual_network_subnet_id = optional(string, null) #The Virtual Network Subnet ID used for this IP Restriction.
    service_tag               = optional(string, null) #The Service Tag used for this IP Restriction.
    headers = optional(list(object({
      x_azure_fdid      = optional(list(string), [])
      x_fd_health_probe = optional(list(string), [])
      x_forwarded_for   = optional(list(string), [])
      x_forwarded_host  = optional(list(string), [])
    })), [])
  }))
  description = "Network (firewall) rules. Type should be ip_address, service_tag, or subnet_id depending on the type of address provided."
  default     = []
}

variable "scm_use_main_ip_restriction" {
  type        = bool
  description = "Should the Windows Function App ip_restriction configuration be used for the SCM also."
  default     = false
}


#Application stack
variable "current_stack" {
  type        = string
  description = "The Application Stack for the Windows Web App. Possible values include dotnet, dotnetcore, node, python, php, and java."
  default = null
}

variable "use_dotnet" {
  type        = bool
  description = "Use .Net programming language."
  default     = false
}
variable "dotnet_version" {
  type        = string
  description = "The version of .NET to use. Possible values include v3.0, v4.0 v6.0, v7.0 and v8.0. Defaults to v8.0."
  default     = "v8.0"
}

variable "use_dotnetcore" {
  type        = bool
  description = "Use .Net Core programming language."
  default     = false
}
variable "dotnetcore_version" {
  type        = string
  description = "The version of .NET to use when current_stack is set to dotnetcore. Possible values include v4.0."
  default     = "v4.0"
}

variable "use_java" {
  type        = bool
  description = "Use Java programming language."
  default     = false
}
variable "java_version" {
  type        = string
  description = "The version of Java to use when current_stack is set to java."
  default     = "17"
}
variable "java_embedded_server_enabled" {
  type        = bool
  description = "Should the Java Embedded Server (Java SE) be used to run the app."
  default     = "false"
}
variable "tomcat_version" {
  type        = string
  description = ") The version of Tomcat the Java App should use. Conflicts with java_embedded_server_enabled"
  default     = ""
}

variable "use_node" {
  type        = bool
  description = "Use Node programming language."
  default     = false
}
variable "node_version" {
  type        = string
  description = "The version of node to use when current_stack is set to node. Possible values are ~12, ~14, ~16, ~18 and ~20. This property conflicts with java_version."
  default     = "~20"
}

variable "use_php" {
  type        = bool
  description = "Use PHP programming language."
  default     = false
}
variable "php_version" {
  type        = string
  description = "The version of PHP to use when current_stack is set to php. Possible values are 7.1, 7.4 and Off. The value Off is used to signify latest supported by the service."
  default     = "7.4"
}

variable "use_python" {
  type        = bool
  description = "Specifies whether this is a Python app."
  default     = false
}

variable "use_docker" {
  type        = bool
  description = "Use Node programming language."
  default     = false
}
variable "docker" {
  type = object({
    registry_url                                  = optional(string, null)
    image_name                                    = optional(string, null)
    container_registry_managed_identity_client_id = optional(string, null)
  })
  description = "One or more docker blocks as defined below."
  default = {
    registry_url                                  = null
    image_name                                    = null
    container_registry_managed_identity_client_id = null
  }
}

variable "webapp_diagnostics_settings" {
  description = "List of diagnostic settings at File level."
  type = list(object({
    name                                 = string,
    log_analytics_workspace_id           = optional(string, null),
    storage_account_id                   = optional(string, null),
    eventhub_authorization_rule_id       = optional(string, null),
    eventhub_name                        = optional(string, null),
    include_diagnostic_metric_categories = optional(bool, true)
  }))
  validation {
    condition     = length(var.webapp_diagnostics_settings) > 0 ? true : false
    error_message = "At least one web app diagnostic setting is required."
  }
}

variable "web_app_slot" {
  description = "Details for creating Web App Slot"
  type = object({
    name                       = string
    auto_swap_slot_name        = optional(string, null)
    service_plan_id            = optional(string, null)
    app_settings               = optional(map(string), {})
    private_endpoint_subnet_id = optional(string, "")
    private_dns_zone_id        = optional(string, "") #For Cigna tenant only
    use_docker                 = optional(bool, false)
    registry_url               = optional(string, null)
    image_name                 = optional(string, null)
    container_registry_managed_identity_client_id = optional(string, null)
    ip_restriction = optional(list(object({
      name                      = string                 #The name which should be used for this ip_restriction.
      priority                  = number                 #The priority value of this ip_restriction. Defaults to 65000.
      action                    = string                 #The action to take. Possible values are Allow or Deny.
      ip_address                = optional(string, null) #The CIDR notation of the IP or IP Range to match. For example: 10.0.0.0/24 or 192.168.10.1/32
      virtual_network_subnet_id = optional(string, null) #The Virtual Network Subnet ID used for this IP Restriction.
      service_tag               = optional(string, null) #The Service Tag used for this IP Restriction.
      headers = optional(list(object({
        x_azure_fdid      = optional(list(string), [])
        x_fd_health_probe = optional(list(string), [])
        x_forwarded_for   = optional(list(string), [])
        x_forwarded_host  = optional(list(string), [])
      })), [])
    })), [])
    scm_ip_restriction = optional(list(object({
      name                      = string                 #The name which should be used for this ip_restriction.
      priority                  = number                 #The priority value of this ip_restriction. Defaults to 65000.
      action                    = string                 #The action to take. Possible values are Allow or Deny.
      ip_address                = optional(string, null) #The CIDR notation of the IP or IP Range to match. For example: 10.0.0.0/24 or 192.168.10.1/32
      virtual_network_subnet_id = optional(string, null) #The Virtual Network Subnet ID used for this IP Restriction.
      service_tag               = optional(string, null) #The Service Tag used for this IP Restriction.
      headers = optional(list(object({
        x_azure_fdid      = optional(list(string), [])
        x_fd_health_probe = optional(list(string), [])
        x_forwarded_for   = optional(list(string), [])
        x_forwarded_host  = optional(list(string), [])
      })), [])
    })), [])


  })

  default = {
    name = ""
  }

}

variable "timeouts" {
  type = object({
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
    active_directory = optional(object({
      allowed_audiences          = optional(list(string), [])
      client_id                  = string
      client_secret              = optional(string, null)
      client_secret_setting_name = optional(string, null)
    }))

  })
  default = {
    enabled = false
    active_directory = {
      client_id = ""
    }
  }
}

variable "auth_settings_v2" {
  description = "Details for auth settings"
  type = object({
    auth_enabled                            = bool #default false
    runtime_version                         = optional(string, null)
    config_file_path                        = optional(string, null)
    require_authentication                  = bool #default false
    unauthenticated_action                  = optional(string, null)
    default_provider                        = optional(string, null)
    excluded_paths                          = optional(list(string))
    require_https                           = bool #Default true
    http_route_api_prefix                   = optional(string, null)
    forward_proxy_convention                = optional(string, null)
    forward_proxy_custom_host_header_name   = optional(string, null)
    forward_proxy_custom_scheme_header_name = optional(string, null)

    active_directory_v2 = optional(object({
      client_id                            = string
      tenant_auth_endpoint                 = string
      client_secret_setting_name           = optional(string, null)
      client_secret_certificate_thumbprint = optional(string, null)
      jwt_allowed_groups                   = optional(list(string))
      jwt_allowed_client_applications      = optional(list(string))
      www_authentication_disabled          = bool #default false
      allowed_groups                       = optional(list(string))
      allowed_audiences                    = optional(list(string))
      allowed_applications                 = optional(list(string))
      allowed_identities                   = optional(list(string))
      login_parameters                     = optional(map(string), {})
    }))

    azure_static_web_app_v2 = optional(object({
      client_id = string
    }))

    microsoft_v2 = optional(object({
      client_id                  = string
      client_secret_setting_name = string
      allowed_audiences          = optional(list(string))
      login_scopes               = optional(list(string))
    }))

    login = optional(object({
      enable_login_settings             = optional(bool, false)
      logout_endpoint                   = optional(string, null)
      token_store_enabled               = bool #default false
      token_refresh_extension_time      = optional(number, 60)
      token_store_path                  = optional(string, null)
      token_store_sas_setting_name      = optional(string, null)
      preserve_url_fragments_for_logins = bool #default false
      allowed_external_redirect_urls    = optional(list(string))
      cookie_expiration_convention      = optional(string, "FixedTime")
      cookie_expiration_time            = optional(string, "08:00:00")
      validate_nonce                    = bool #default false
      nonce_expiration_time             = optional(string, "00:05:00")
    }))

  })

  default = {
    auth_enabled           = false
    require_authentication = true
    require_https          = true

  }
}

#Monitoring alerts

variable "include_alerts" {
  description = "Include built-in module alerts."
  type        = bool
  default     = true
}

variable "include_alert_action_group" {
  description = "Include alert action group."
  type        = bool
  default     = false
}

variable "alert_email_addresses" {
  description = "List of email addresses to use for alert notifications."
  type        = list(string)
  default     = []
}

variable "alarm_funnel_environment" {
  description = "Environment Alarm Funnel will be triggered"
  type        = string
  default     = ""
}

variable "alerts" {
  description = "Alert configuration"
  type = object({

    webapp_stopped = optional(object({
      include               = optional(bool, true)
      alarm_funnel_severity = optional(string, "WARN")
      }), { include         = true
      alarm_funnel_severity = "WARN"
    })

    http_server_errors = optional(object({
      include                  = optional(bool, true)
      use_dynamic_criteria     = optional(bool, false)
      alarm_funnel_severity    = optional(string, "CRITICAL")
      alert_severity           = optional(number, 0)
      aggregation              = optional(string, "Total")
      operator                 = optional(string, "GreaterThan")
      threshold                = optional(number, 4)
      frequency                = optional(string, "PT1M")
      window_size              = optional(string, "PT5M")
      auto_mitigate            = optional(bool, true)
      alert_sensitivity        = optional(string, "Medium")
      evaluation_total_count   = optional(number, 4)
      evaluation_failure_count = optional(number, 4)
      }), {
      include                  = true
      use_dynamic_criteria     = false
      alarm_funnel_severity    = "CRITICAL"
      alert_severity           = 0
      aggregation              = "Total"
      operator                 = "GreaterThan"
      threshold                = 4
      frequency                = "PT1M"
      window_size              = "PT5M"
      auto_mitigate            = true
      alert_sensitivity        = "Medium"
      evaluation_total_count   = 4
      evaluation_failure_count = 4
    })

    health_check = optional(object({
      include                   = optional(bool, true)
      use_dynamic_criteria      = optional(bool, false)
      alarm_funnel_severity     = optional(string, "WARN")
      alert_severity            = optional(number, 2)
      aggregation               = optional(string, "Average")
      operator                  = optional(string, "LessThan")
      threshold                 = optional(number, 100)
      frequency                 = optional(string, "PT1M")
      window_size               = optional(string, "PT5M")
      auto_mitigate             = optional(bool, true)
      alert_sensitivity         = optional(string, "Medium")
      evaluation_total_count    = optional(number, 4)
      evaluation_failure_count  = optional(number, 4)
      include_default_dimension = optional(bool, false)
      }), {
      include                   = true
      use_dynamic_criteria      = false
      alarm_funnel_severity     = "WARN"
      alert_severity            = 2
      aggregation               = "Average"
      operator                  = "LessThan"
      threshold                 = 100
      frequency                 = "PT1M"
      window_size               = "PT5M"
      auto_mitigate             = true
      alert_sensitivity         = "Medium"
      evaluation_total_count    = 4
      evaluation_failure_count  = 4
      include_default_dimension = false
    })

    cpu_percentage = optional(object({
      include                   = optional(bool, true)
      use_dynamic_criteria      = optional(bool, false)
      alarm_funnel_severity     = optional(string, "WARN")
      alert_severity            = optional(number, 2)
      aggregation               = optional(string, "Average")
      operator                  = optional(string, "GreaterThan")
      threshold                 = optional(number, 80)
      frequency                 = optional(string, "PT1M")
      window_size               = optional(string, "PT5M")
      auto_mitigate             = optional(bool, true)
      alert_sensitivity         = optional(string, "Medium")
      evaluation_total_count    = optional(number, 4)
      evaluation_failure_count  = optional(number, 4)
      include_default_dimension = optional(bool, false)
      }), {
      include                   = true
      use_dynamic_criteria      = false
      alarm_funnel_severity     = "WARN"
      alert_severity            = 2
      aggregation               = "Average"
      operator                  = "GreaterThan"
      threshold                 = 80
      frequency                 = "PT1M"
      window_size               = "PT5M"
      auto_mitigate             = true
      alert_sensitivity         = "Medium"
      evaluation_total_count    = 4
      evaluation_failure_count  = 4
      include_default_dimension = false
    })

    memory_percentage = optional(object({
      include                   = optional(bool, true)
      use_dynamic_criteria      = optional(bool, false)
      alarm_funnel_severity     = optional(string, "WARN")
      alert_severity            = optional(number, 2)
      aggregation               = optional(string, "Average")
      operator                  = optional(string, "GreaterThan")
      threshold                 = optional(number, 90)
      frequency                 = optional(string, "PT1M")
      window_size               = optional(string, "PT5M")
      auto_mitigate             = optional(bool, true)
      alert_sensitivity         = optional(string, "Medium")
      evaluation_total_count    = optional(number, 4)
      evaluation_failure_count  = optional(number, 4)
      include_default_dimension = optional(bool, false)
      }), {
      include                   = true
      use_dynamic_criteria      = false
      alarm_funnel_severity     = "WARN"
      alert_severity            = 2
      aggregation               = "Average"
      operator                  = "GreaterThan"
      threshold                 = 90
      frequency                 = "PT1M"
      window_size               = "PT5M"
      auto_mitigate             = true
      alert_sensitivity         = "Medium"
      evaluation_total_count    = 4
      evaluation_failure_count  = 4
      include_default_dimension = false
    })

    http_queue_length = optional(object({
      include                   = optional(bool, true)
      use_dynamic_criteria      = optional(bool, false)
      alarm_funnel_severity     = optional(string, "WARN")
      alert_severity            = optional(number, 2)
      aggregation               = optional(string, "Average")
      operator                  = optional(string, "GreaterThan")
      threshold                 = optional(number, 85)
      frequency                 = optional(string, "PT1M")
      window_size               = optional(string, "PT5M")
      auto_mitigate             = optional(bool, true)
      alert_sensitivity         = optional(string, "Medium")
      evaluation_total_count    = optional(number, 4)
      evaluation_failure_count  = optional(number, 4)
      include_default_dimension = optional(bool, false)
      }), {
      include                   = true
      use_dynamic_criteria      = false
      alarm_funnel_severity     = "WARN"
      alert_severity            = 2
      aggregation               = "Average"
      operator                  = "GreaterThan"
      threshold                 = 85
      frequency                 = "PT1M"
      window_size               = "PT5M"
      auto_mitigate             = true
      alert_sensitivity         = "Medium"
      evaluation_total_count    = 4
      evaluation_failure_count  = 4
      include_default_dimension = false
    })

  })
  default = {

    webapp_stopped = {
      include               = true
      alarm_funnel_severity = "WARN"
    }

    http_server_errors = {
      include                  = true
      use_dynamic_criteria     = false
      alarm_funnel_severity    = "CRITICAL"
      alert_severity           = 0
      aggregation              = "Total"
      operator                 = "GreaterThan"
      alert_sensitivity        = "Medium"
      evaluation_total_count   = 4
      evaluation_failure_count = 4
      frequency                = "PT1M"
      window_size              = "PT5M"
      auto_mitigate            = true
    }

    health_check = {
      include               = true
      use_dynamic_criteria  = false
      alarm_funnel_severity = "WARN"
      alert_severity        = 2
      aggregation           = "Average"
      operator              = "LessThan"
      threshold             = 100
      frequency             = "PT1M"
      window_size           = "PT5M"
      auto_mitigate         = true
    }

    cpu_percentage = {
      include               = true
      use_dynamic_criteria  = false
      alarm_funnel_severity = "WARN"
      alert_severity        = 2
      aggregation           = "Average"
      operator              = "GreaterThan"
      threshold             = 80
      frequency             = "PT1M"
      window_size           = "PT5M"
      auto_mitigate         = true
    }

    memory_percentage = {
      include               = true
      use_dynamic_criteria  = false
      alarm_funnel_severity = "WARN"
      alert_severity        = 2
      aggregation           = "Average"
      operator              = "GreaterThan"
      threshold             = 90
      frequency             = "PT1M"
      window_size           = "PT5M"
      auto_mitigate         = true
    }

    http_queue_length = {
      include               = true
      use_dynamic_criteria  = false
      alarm_funnel_severity = "WARN"
      alert_severity        = 2
      aggregation           = "Average"
      operator              = "GreaterThan"
      threshold             = 85
      frequency             = "PT1M"
      window_size           = "PT5M"
      auto_mitigate         = true
    }

  }

}

variable "logs" {
  type = object({
    detailed_error_messages = optional(bool, false)
    failed_request_tracing  = optional(bool, false)
    application_logs = optional(object({
      azure_blob_storage = optional(object({
        level             = string
        retention_in_days = number
        sas_url           = string
      }), null)
      file_system_level = string #Possible values include: Off, Verbose, Information, Warning, and Error.
    }), null)
    http_logs = optional(object({
      azure_blob_storage = optional(object({
        retention_in_days = number
        sas_url           = string
      }), null)
      file_system = optional(object({
        retention_in_days = number
        retention_in_mb   = number

      }), null)

    }), null)
  })

  description = "Log block for adding logs."
  default     = null

}

variable "alarm_funnel_app_name" {
  description = "App Name used when registering in the alarm funnel yaml file. The variable var.name will be used if this variable is not set."
  type        = string
  default     = null
}

variable "external_action_group_id" {
  description = "Action Group Id created outside of the module"
  type        = string
  default     = null
}

variable "minimum_tls_version" {
  description = "Configures the minimum version of TLS required for SSL requests. Possible values include: 1.2 and 1.3. Defaults to 1.3."
  type        = string
  default     = "1.3"
  validation {
    condition     = var.minimum_tls_version == "1.2" || var.minimum_tls_version == "1.3"
    error_message = "The minimum_tls_version value must be 1.2 or 1.3."
  }
}

variable "scm_minimum_tls_version" {
  description = "Configures the minimum version of TLS required for SSL requests. Possible values include: 1.2 and 1.3. Defaults to 1.3."
  type        = string
  default     = "1.3"

  validation {
    condition     = var.scm_minimum_tls_version == "1.2" || var.scm_minimum_tls_version == "1.3"
    error_message = "The scm_minimum_tls_version value must be 1.2 or 1.3."
  }

}
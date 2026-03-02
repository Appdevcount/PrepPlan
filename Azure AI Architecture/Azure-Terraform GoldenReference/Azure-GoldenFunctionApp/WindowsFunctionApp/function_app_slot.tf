resource "azurerm_windows_function_app_slot" "slot" {
  depends_on                    = [ azurerm_windows_function_app.function  ]
  count                         = var.include_function_app_slot == true ? 1 : 0
  name                          = var.function_app_slot.name
  function_app_id               = azurerm_windows_function_app.function.id
  tags                          = local.tags

  #App Service Plan
  service_plan_id               = var.function_app_slot.service_plan_id

  #Storage
  storage_account_name          = var.storage_account_name 
  storage_uses_managed_identity = true
  
  #Security
  client_certificate_enabled    = var.client_certificate_enabled
  client_certificate_mode       = var.client_certificate_mode
  https_only                    = true

  #Logging
  builtin_logging_enabled       = var.builtin_logging_enabled

  #Networking
  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_subnet_id     = var.virtual_network_subnet_id

  #Configuration
  functions_extension_version   = var.functions_extension_version
  app_settings                  = var.function_app_slot.app_settings

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  site_config {
    always_on                                     = var.always_on #NOTE: When running in a Consumption or Premium Plan, always_on feature should be turned off. Please turn it off before upgrading the service plan from standard to premium.
    application_insights_connection_string        = var.include_app_insights == true ? azurerm_application_insights.appinsights.0.connection_string : var.appinsights_connection_string
    application_insights_key                      = var.include_app_insights == true ? azurerm_application_insights.appinsights.0.instrumentation_key : var.application_insights_key
    ftps_state                                    = var.ftps_state
    http2_enabled                                 = true
    vnet_route_all_enabled                        = var.vnet_route_all_enabled
    ip_restriction_default_action                 = "Deny" #Requires azurerm 3.95 or higher
    scm_ip_restriction_default_action             = "Deny" #Requires azurerm 3.95 or higher
    use_32_bit_worker                             = var.use_32_bit_worker
    elastic_instance_minimum                      = var.elastic_instance_minimum # The number of minimum instances for this Windows Function App. Only affects apps on Elastic Premium plans.
    app_scale_limit                               = var.app_scale_limit # The number of workers this function app can scale out to. Only applicable to apps on the Consumption and Premium plan.
    pre_warmed_instance_count                     = var.pre_warmed_instance_count  # Only affects apps on an Elastic Premium plan.
    worker_count                                  = var.app_worker_count # Setting this will also change it at the app serice plan level.
    runtime_scale_monitoring_enabled              = var.runtime_scale_monitoring_enabled # Use only for Elastic Plan

    default_documents                             = var.default_documents
    health_check_path                             = var.health_check_path 
    health_check_eviction_time_in_min             = var.health_check_eviction_time_in_min
    load_balancing_mode                           = var.load_balancing_mode

    #NOTE: If this is set, there must not be an application setting FUNCTIONS_WORKER_RUNTIME.
    dynamic "application_stack" {
      for_each = var.use_dotnet ? ["use_dotnet"] : []
      content{
               dotnet_version = var.dotnet_version
               use_dotnet_isolated_runtime = var.use_dotnet_isolated_runtime
             }
    }

    dynamic "application_stack" {
      for_each = var.use_java ? ["use_java"] : []
      content {
               java_version = var.java_version
              }
    }

    dynamic "application_stack" {
      for_each = var.use_node ? ["use_node"] : []
      content {
               node_version = var.node_version
              }
    }

    dynamic "application_stack" {
      for_each = var.use_powershell ? ["use_powershell"] : []
      content{
               powershell_core_version = var.powershell_core_version
             }
    }

    cors {
          allowed_origins     = var.allowed_origins
          support_credentials = var.support_credentials
          }   

    dynamic "ip_restriction" {
      for_each = var.function_app_slot.ip_restriction
      content {
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action
        ip_address                = ip_restriction.value.ip_address
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
        headers                   = ip_restriction.value.headers
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = var.function_app_slot.scm_ip_restriction
      content {
        name                      = scm_ip_restriction.value.name
        priority                  = scm_ip_restriction.value.priority
        action                    = scm_ip_restriction.value.action
        ip_address                = scm_ip_restriction.value.ip_address
        service_tag               = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
        headers                   = scm_ip_restriction.value.headers
      }
    }        

  }

  
  
  identity {
    type = var.identity_type
    identity_ids = local.identity_ids
  }

  timeouts {
    create = var.timeouts.create
    read   = var.timeouts.read
    update = var.timeouts.update
    delete = var.timeouts.delete
  } 
}
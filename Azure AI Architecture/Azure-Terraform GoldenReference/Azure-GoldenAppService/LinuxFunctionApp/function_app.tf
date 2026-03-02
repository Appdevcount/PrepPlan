resource "azurerm_linux_function_app" "function" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location

  storage_account_name          = var.storage_account_name 
  storage_account_access_key    = var.storage_uses_managed_identity ? null : var.storage_account_access_key
  storage_uses_managed_identity = var.storage_uses_managed_identity == false ? null : true
  service_plan_id               = var.service_plan_id
  client_certificate_enabled    = var.client_certificate_enabled
  client_certificate_mode       = var.client_certificate_mode
  https_only                    = true
  builtin_logging_enabled       = var.builtin_logging_enabled
  virtual_network_subnet_id     = var.virtual_network_subnet_id

  app_settings = var.app_settings

  dynamic "sticky_settings" {
    for_each = var.sticky_settings_app_setting_names != null  || var.sticky_settings_connection_string_names != null  ? ["use_sticky_settings"] : []
    content {
              app_setting_names = var.sticky_settings_app_setting_names 
              connection_string_names = var.sticky_settings_connection_string_names
            }
  }

  site_config {
    always_on                                     = var.always_on
    application_insights_connection_string        = var.appinsights_connection_string
    ftps_state                                    = var.ftps_state
    http2_enabled                                 = true
    vnet_route_all_enabled                        = length(var.virtual_network_subnet_id) > 0 ? true : false
    ip_restriction_default_action                 = var.ip_restriction_default_action
    scm_ip_restriction_default_action             = var.scm_ip_restriction_default_action
    container_registry_managed_identity_client_id = null
    container_registry_use_managed_identity       = false

    dynamic "application_stack" {
        for_each = false ? ["use_dotnet"] : []
      content{
               dotnet_version = ""
               use_dotnet_isolated_runtime = false
             }
    }

    dynamic "application_stack" {
      for_each = true ? ["use_python"] : []
      content {
               python_version = "3.10"
             }
    }

    dynamic "application_stack" {
      for_each = false ? ["use_docker"] : []
      content {
               docker {
                        registry_url = ""
                        image_name = ""
                        image_tag = ""
                      }
              
              }
    }        

    dynamic "application_stack" {
      for_each = false ? ["use_java"] : []
      content {
               java_version = "3.10"
              }
    }

    dynamic "application_stack" {
      for_each = false ? ["use_powershell"] : []
      content{
               powershell_core_version = "3.10"
             }
    }

    cors {
          allowed_origins     = var.allowed_origins
          support_credentials = var.support_credentials
    }

    dynamic "ip_restriction" {
      for_each = var.ip_restriction
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
      for_each = var.scm_ip_restriction
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
    type = "SystemAssigned"
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
      tags["hidden-link: /app-insights-conn-string"]
    ]
  } 
}
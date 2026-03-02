locals {
  identity_ids = var.identity_type == "SystemAssigned" ? [] : var.user_assigned_identity_ids
}

resource "azurerm_windows_function_app" "function" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location

  storage_account_name          = var.storage_account_name 
  storage_account_access_key    = var.storage_uses_managed_identity ? null : var.storage_account_access_key
  storage_uses_managed_identity = var.storage_uses_managed_identity == false ? null : true
  service_plan_id               = var.include_app_service_plan == true ? azurerm_service_plan.asp.0.id : var.service_plan_id
  client_certificate_enabled    = var.client_certificate_enabled
  client_certificate_mode       = var.client_certificate_mode
  https_only                    = true
  builtin_logging_enabled       = var.builtin_logging_enabled
  virtual_network_subnet_id     = var.virtual_network_subnet_id
  
  app_settings = var.app_settings

/*   backup {
    name = "BackupTest"
    schedule {
      frequency_interval = 7
      frequency_unit = "Hour"
      keep_at_least_one_backup = true
      retention_period_days = 30
      start_time = "2024-04-29T01:00:00.000Z"
    }
    storage_account_url = "https://${var.storage_account_name}.blob.core.windows.net/${var.storage_account_backup_container_name}${var.storage_account_backup_container_sas}"  
    enabled = true
  } */

  dynamic "sticky_settings" {
    for_each = var.sticky_settings_app_setting_names != null  || var.sticky_settings_connection_string_names != null  ? ["use_sticky_settings"] : []
    content {
              app_setting_names = var.sticky_settings_app_setting_names 
              connection_string_names = var.sticky_settings_connection_string_names
            }
  }

  site_config {
    always_on                                     = var.always_on
    application_insights_connection_string        = var.include_app_insights == true ? azurerm_application_insights.appinsights.0.connection_string : var.appinsights_connection_string
    application_insights_key                      = var.include_app_insights == true ? azurerm_application_insights.appinsights.0.instrumentation_key : var.application_insights_key
    ftps_state                                    = var.ftps_state
    http2_enabled                                 = true
    vnet_route_all_enabled                        = length(var.virtual_network_subnet_id) > 0 ? true : false
    ip_restriction_default_action                 = var.ip_restriction_default_action
    scm_ip_restriction_default_action             = var.scm_ip_restriction_default_action
    use_32_bit_worker                             = var.use_32_bit_worker
    elastic_instance_minimum                      = var.elastic_instance_minimum # Always Ready Instances for Elastic Plan
    app_scale_limit                               = var.app_scale_limit # Maximum Scale Limit (> 0 turns on Scale Out Limit = yes)
    pre_warmed_instance_count                     = var.pre_warmed_instance_count  # N/A for Elastic PLan
    worker_count                                  = var.app_worker_count # Setting this will also change it at the app serice plan level.
    runtime_scale_monitoring_enabled              = var.runtime_scale_monitoring_enabled # Use only for Elastic Plan

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
    type = var.identity_type
    identity_ids = local.identity_ids
  }

  tags = local.tags

/*   lifecycle {
    ignore_changes = [
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
      tags["hidden-link: /app-insights-conn-string"]
    ]
  }  */
}
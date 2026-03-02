resource "azurerm_windows_web_app_slot" "slot" {
  depends_on     = [azurerm_windows_web_app.web]
  count          = var.include_web_app_slot == true ? 1 : 0
  name           = var.web_app_slot.name
  app_service_id = azurerm_windows_web_app.web.id
  tags           = local.tags

  #App Service Plan
  service_plan_id = var.web_app_slot.service_plan_id

  #Security
  client_certificate_enabled = var.client_certificate_enabled
  client_certificate_mode    = var.client_certificate_mode
  https_only                 = true
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled
  ftp_publish_basic_authentication_enabled = var.ftp_publish_basic_authentication_enabled 
  
  #Networking
  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_subnet_id     = var.virtual_network_subnet_id

  #Security
  dynamic "auth_settings" {
    for_each = var.auth_settings.enabled ? ["configure_settings"] : []
    content {
      enabled                        = var.auth_settings.enabled
      additional_login_parameters    = var.auth_settings.additional_login_parameters
      allowed_external_redirect_urls = var.auth_settings.allowed_external_redirect_urls
      default_provider               = var.auth_settings.default_provider
      runtime_version                = var.auth_settings.runtime_version
      token_refresh_extension_hours  = var.auth_settings.token_refresh_extension_hours
      token_store_enabled            = var.auth_settings.token_store_enabled
      unauthenticated_client_action  = var.auth_settings.unauthenticated_client_action

      dynamic "active_directory" {
        for_each = length(var.auth_settings.active_directory.client_id) > 0 ? ["configure_ad"] : []
        content {
          allowed_audiences          = var.auth_settings.active_directory.allowed_audiences
          client_id                  = var.auth_settings.active_directory.client_id
          client_secret              = var.auth_settings.active_directory.client_secret
          client_secret_setting_name = var.auth_settings.active_directory.client_secret_setting_name
        }
      }
    }
  }

  #Deployment
  zip_deploy_file = var.zip_deploy_file

  #Configuration
  client_affinity_enabled = var.client_affinity_enabled


  dynamic "storage_account" {
    for_each = var.storage_account != null ? ["use_storageaccount"] : []
    content {
      access_key   = var.storage_account.access_key
      account_name = var.storage_account.account_name
      name         = var.storage_account.name
      share_name   = var.storage_account.share_name
      type         = var.storage_account.type
      mount_path   = var.storage_account.mount_path
    }
  }

  dynamic "logs" {
    for_each = var.logs != null ? ["add_logs"] : []
    content {
      detailed_error_messages = var.logs.detailed_error_messages
      failed_request_tracing  = var.logs.failed_request_tracing

      dynamic "application_logs" {
        for_each = var.logs.application_logs != null ? ["add_application_logs"] : []
        content {
          file_system_level = var.logs.application_logs.file_system_level
          dynamic "azure_blob_storage" {
            for_each = var.logs.application_logs.azure_blob_storage != null ? ["azure_blob_storage"] : []
            content {
              level             = var.logs.application_logs.azure_blob_storage.level
              retention_in_days = var.logs.application_logs.azure_blob_storage.retention_in_days
              sas_url           = var.logs.application_logs.azure_blob_storage.sas_url
            }
          }
        }
      }

      dynamic "http_logs" {
        for_each = var.logs.http_logs != null ? ["add_http_logs"] : []
        content {
          dynamic "azure_blob_storage" {
            for_each = var.logs.http_logs.azure_blob_storage != null ? ["add_azure_blob_storage"] : []
            content {
              retention_in_days = var.logs.http_logs.azure_blob_storage.retention_in_days
              sas_url           = var.logs.http_logs.azure_blob_storage.sas_url
            }
          }

          dynamic "file_system" {
            for_each = var.logs.http_logs.file_system != null ? ["add_file_system"] : []
            content {
              retention_in_days = var.logs.http_logs.file_system.retention_in_days
              retention_in_mb   = var.logs.http_logs.file_system.retention_in_mb
            }
          }

        }
      }
    }
  }


  app_settings = var.include_app_insights ? merge(var.web_app_slot.app_settings,
    { APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.appinsights.0.instrumentation_key
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.appinsights.0.connection_string
  ApplicationInsightsAgent_EXTENSION_VERSION = "~2" }) : var.web_app_slot.app_settings

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }


  site_config {
    always_on                         = var.always_on #always_on must be explicitly set to false when using Free, F1, D1, or Shared Service Plans.
    ftps_state                        = "Disabled"
    http2_enabled                     = true
    vnet_route_all_enabled            = var.vnet_route_all_enabled
    ip_restriction_default_action     = "Deny" #Requires azurerm 3.95 or higher
    scm_ip_restriction_default_action = "Deny" #Requires azurerm 3.95 or higher
    scm_use_main_ip_restriction       = var.scm_use_main_ip_restriction
    use_32_bit_worker                 = var.use_32_bit_worker
    worker_count                      = var.app_worker_count # Setting this will also change it at the app serice plan level.

    minimum_tls_version               = var.minimum_tls_version
    scm_minimum_tls_version           = var.scm_minimum_tls_version
    managed_pipeline_mode             = var.managed_pipeline_mode
    default_documents                 = var.default_documents
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min
    load_balancing_mode               = var.load_balancing_mode
    auto_swap_slot_name               = var.web_app_slot.auto_swap_slot_name

    #Docker Managed Identity
    container_registry_managed_identity_client_id = var.docker.container_registry_managed_identity_client_id
    container_registry_use_managed_identity       = true


    #Application stack
    application_stack {
      current_stack       = var.current_stack
      dotnet_version      = var.use_dotnet ? var.dotnet_version : null
      dotnet_core_version = var.use_dotnetcore ? var.dotnetcore_version : null
      java_version        = var.use_java ? var.java_version : null
      tomcat_version      = var.use_java ? var.tomcat_version : null #Use with Java 
      node_version        = var.use_node ? var.node_version : null
      php_version         = var.use_php ? var.php_version : null
      python              = var.use_python
      docker_image_name   = var.web_app_slot.use_docker ? var.web_app_slot.image_name : null
      docker_registry_url = var.web_app_slot.use_docker ? var.web_app_slot.registry_url : null

    }

    #Other configurations
    remote_debugging_enabled = var.remote_debugging_enabled

    dynamic "virtual_application" {
      for_each = var.virtual_application
      content {
        physical_path = virtual_application.value.physical_path
        preload       = virtual_application.value.preload
        virtual_path  = virtual_application.value.virtual_path
        dynamic "virtual_directory" {
          for_each = virtual_application.value.virtual_directory
          content {
            physical_path = virtual_directory.value.physical_path
            virtual_path  = virtual_directory.value.virtual_path
          }

        }
      }
    }

    cors {
      allowed_origins     = var.allowed_origins
      support_credentials = var.support_credentials
    }


    dynamic "ip_restriction" {
      for_each = var.web_app_slot.ip_restriction
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
      for_each = var.web_app_slot.scm_ip_restriction
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
    type         = var.identity_type
    identity_ids = local.identity_ids
  }



  timeouts {
    create = var.timeouts.create
    read   = var.timeouts.read
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  lifecycle {

    precondition {
      condition     = var.include_alert_action_group ? length(var.alert_email_addresses) > 0 : true
      error_message = "At least one email address is required when including alerts."
    }

    precondition {
      condition     = var.include_alerts ? var.alarm_funnel_environment != "" && contains(local.valid_alarm_funnel_environments, upper(var.alarm_funnel_environment)) : true
      error_message = "When including alerts, var.alarm_funnel_environment value is required. Valid values: ${local.valid_alarm_funnel_environments_string}"
    }

  }
}
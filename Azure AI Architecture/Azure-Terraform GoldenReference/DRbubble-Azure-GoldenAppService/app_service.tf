resource "azurerm_app_service" "webapp" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  app_service_plan_id     = azurerm_app_service_plan.asp.id
  client_affinity_enabled = var.client_affinity_enabled
  client_cert_enabled     = var.client_cert_enabled
  enabled                 = true
  https_only              = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                = lookup(local.site_configs, "alwasy_on", null)
    app_command_line         = lookup(local.site_configs, "app_command_line", null)
    dotnet_framework_version = lookup(local.site_configs, "dotnet_framework_version", null)
    health_check_path        = lookup(local.site_configs, "health_check_path", null)
    java_version             = lookup(local.site_configs, "java_version", null)
    java_container_version   = lookup(local.site_configs, "java_container_version", null)
    java_container           = lookup(local.site_configs, "java_container", null)
    php_version              = lookup(local.site_configs, "php_version", null)
    python_version           = lookup(local.site_configs, "python_version", null)
    http2_enabled            = lookup(local.site_configs, "http2_enabled", null)
    vnet_route_all_enabled   = lookup(local.site_configs, "vnet_route_all_enabled", null)
    websockets_enabled       = lookup(local.site_configs, "websockets_enabled", null)
    ftps_state               = "Disabled"

    dynamic "ip_restriction" {
      for_each = var.ip_restriction
      content {
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action
        ip_address                = ip_restriction.value.type == "ip_address" ? ip_restriction.value.address : null
        service_tag               = ip_restriction.value.type == "service_tag" ? ip_restriction.value.address : null
        virtual_network_subnet_id = ip_restriction.value.type == "subnet_id" ? ip_restriction.value.address : null
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = var.scm_ip_restriction
      content {
        name                      = scm_ip_restriction.value.name
        priority                  = scm_ip_restriction.value.priority
        action                    = scm_ip_restriction.value.action
        ip_address                = scm_ip_restriction.value.type == "ip_address" ? scm_ip_restriction.value.address : null
        service_tag               = scm_ip_restriction.value.type == "service_tag" ? scm_ip_restriction.value.address : null
        virtual_network_subnet_id = scm_ip_restriction.value.type == "subnet_id" ? scm_ip_restriction.value.address : null
      }
    }

    cors {
      allowed_origins     = var.cors_allowed_origins
      support_credentials = false
    }
  }

  app_settings = local.expanded_app_settings

  auth_settings {
    enabled                       = var.auth_settings.enabled
    unauthenticated_client_action = var.auth_settings.enabled == true ? "RedirectToLoginPage" : null
    active_directory {
      client_id         = var.auth_settings.client_id
      allowed_audiences = var.auth_settings.allowed_audiences
    }
  }

  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  #This feature is not documented (therefor not implemented), and should not be used. It is
  #included here only to provide a rapid release of storage support if a valid use-case
  #comes through intake requireing blob storage.
  dynamic "storage_account" {
    for_each = var.storage_account == null ? [] : tolist([var.storage_account])
    content {
      name         = storage_account.value.name
      type         = "AzureBlob"
      account_name = storage_account.value.account_name
      share_name   = storage_account.value.share_name
      access_key   = storage_account.value.access_key
    }
  }

  dynamic "logs" {
    for_each = var.logs == null ? [] : tolist([var.logs])
    content {
      detailed_error_messages_enabled = logs.detailed_error_messages_enabled.value
      failed_request_tracing_enabled  = logs.failed_request_tracing_enabled.value
      application_logs {
        azure_blob_storage {
          level             = logs.level.value
          sas_url           = logs.level.sas_url.value
          retention_in_days = logs.retention_in_days.value
        }
      }
      http_logs {
        azure_blob_storage {
          sas_url           = logs.level.sas_url.value
          retention_in_days = logs.retention_in_days.value
        }
      }
    }
  }

  tags = local.tags
}
# This file should only contain local variable declarations that are used globally within a module. If
# a local is defined to support creation of a specific resource, that local should be included in the same
# .tf file as the resource being created to improve code readability.

locals {
  tags = merge(
    var.required_tags,
    var.user_defined_tags
  )

  pe_app_settings = {
    WEBSITE_DNS_SERVER     = "168.63.129.16",
    WEBSITE_VNET_ROUTE_ALL = "1"
  }

  expanded_app_settings = upper(substr(var.sku, 0, 1)) == "P" ? merge(var.app_settings, local.pe_app_settings) : var.app_settings

  req_site_config = {
    ftps_state      = "Disabled",
    min_tls_version = "1.2"
  }

  #does not support CORS origins block -- add for V2
  site_configs = merge(
    var.site_config,
    local.req_site_config
  )
}
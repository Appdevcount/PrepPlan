resource "azurerm_key_vault" "kv" {
  sku_name                        = var.sku_name
  name                            = var.name
  tenant_id                       = var.tenant_id == null ? data.azurerm_client_config.current.tenant_id : var.tenant_id
  location                        = var.location
  resource_group_name             = var.resource_group_name
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
  soft_delete_retention_days      = var.soft_delete_retention
  purge_protection_enabled        = var.enable_purge_protection
  enable_rbac_authorization       = var.enable_rbac_authorization
  public_network_access_enabled   = var.public_network_access
  tags = local.tags

  network_acls {
    default_action             = "Deny"
    bypass                     = var.bypass_trusted_services ? "AzureServices" : "None"
    ip_rules                   = var.public_network_access ? local.allowed_ips : null
    virtual_network_subnet_ids = var.public_network_access ? var.virtual_network_subnet_ids : null
  }


  lifecycle {
    precondition {
      condition     = var.public_network_access ? true : length(var.private_endpoint_subnet_id) > 0
      error_message = "Private Endpoints are required when public_network_access is set to: false."
    }
    precondition {
      condition     = var.public_network_access ? local.has_configured_firewall : true
      error_message = "KeyVault networking requires a list of allowed IPs and\\or list of allowed subnets when public access is enabled."
    }
    precondition {
      condition     = var.include_ado_cidrs ? var.public_network_access : true
      error_message = "KeyVault public access must be enabled when including ADO CIDRs."
    }
    precondition {
      condition     = local.create_private_endpoint && local.enable_private_dns_zone_group ? length(var.private_dns_zone_id) > 0 : true
      error_message = "Variable private_dns_zone_id must be set for this tenant: ${data.azurerm_client_config.current.tenant_id}."
    }
    precondition {
      condition     = length(keys(local.tags)) > 15 ? false : true
      error_message = "Key Vault resources have a max tag limit of 15. Actual number of tags to add = ${length(keys(local.tags))}"
    }
  }
}
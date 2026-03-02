locals {
  principal_type = var.enable_ccoe_local_testing ? "User" : "ServicePrincipal"
  keyvault_id = var.cmk_keyvault.create_new_keyvault ? module.sa_cmk_key_vault[0].key_vault_id : var.cmk_keyvault.id
  cmk_keyvault_enable_rbac = var.cmk_keyvault.create_new_keyvault ? true : var.cmk_keyvault.enable_rbac_authorization
}

module "sa_cmk_key_vault" {

  source = "git::ssh://git@ssh.dev.azure.com/v3/eviCoreDev/Reusable%20Code/Azure-GoldenKeyVault?ref=v5.0.1"
  count                           = var.cmk_keyvault.create_new_keyvault ? 1 : 0
  TimerDelay                      = var.TimerDelay
  
  # replace these with your values
  resource_group_name             = var.resource_group_name
  name                            = var.cmk_keyvault.name
  location                        = var.location

  initial_access_assignments      = [
                                      {
                                        principal_id   = "self"
                                        roles          = ["Key Vault Administrator", "Key Vault Crypto Officer"]
                                        principal_type = local.principal_type # Note: principal_type = User is only allowed for CCOE for testing purposes. Use ServicePrincipal or Group with RASS.
                                      }
                                    ]

  #enable_rbac_authorization       = var.cmk_keyvault.rbac_enabled
  enable_rbac_authorization       = local.cmk_keyvault_enable_rbac

  #Policy: Key vaults should have soft delete enabled
  #soft_delete_retention           = var.soft_delete_retention
  
  #Policy: Key vaults should have deletion protection enabled
  #enable_purge_protection = var.enable_purge_protection

  #Policy: Global Tags Policy
  required_tags                   = var.required_tags
  optional_tags                   = var.optional_tags

  #Policy: Azure Key Vault should disable public network access
  #Note: When public_network_access_enabled = false, Private Endpoints are required
  #public_network_access           = var.public_network_access_enabled
  public_network_access           = var.cmk_keyvault.allow_public_network_access

  #Policy: Azure Key Vault should have firewall enabled
  #Policy: Configure key vaults to enable firewall
  #Policy: Key Vault should use a virtual network service endpoint
  virtual_network_subnet_ids      = var.cmk_keyvault.allowed_subnet_ids 
  allowed_ip_rules                = var.cmk_keyvault.allowed_public_ips


  #Policy: Deploy - Configure diagnostic settings for Azure Key Vault to Log Analytics workspace
  #Policy: Deploy Diagnostic Settings for Key Vault to Event Hub
  #Policy: Deploy Diagnostic Settings for Key Vault to Log Analytics workspace
  keyvault_diagnostics_settings   = [
                                     {
                                        name                                 = "keyvault-cmk"  
                                        storage_account_id                   = var.storage_diagnostics_settings[0].storage_account_id == "" ? null : var.storage_diagnostics_settings[0].storage_account_id
                                        log_analytics_workspace_id           = var.storage_diagnostics_settings[0].log_analytics_workspace_id == "" ? null : var.storage_diagnostics_settings[0].log_analytics_workspace_id
                                        eventhub_authorization_rule_id       = var.storage_diagnostics_settings[0].eventhub_authorization_rule_id == "" ? null : var.storage_diagnostics_settings[0].eventhub_authorization_rule_id
                                        eventhub_name                        = var.storage_diagnostics_settings[0].eventhub_name == "" ? null : var.storage_diagnostics_settings[0].eventhub_name
                                        include_diagnostic_log_categories    = true
                                        include_diagnostic_metric_categories = true  
                                     }
                                    ]
  
  #Policy: Configure Azure Key Vaults with private endpoints
  #Policy: Azure Key Vaults should use private link
  private_endpoint_subnet_id      = var.cmk_keyvault.private_endpoint_subnet_id
  private_dns_zone_id             = var.cmk_keyvault.private_dns_zone_id
   
  bypass_trusted_services         = true
  keyvault_keys                   = {
                                      "storage-account-cmk-key" = {
                                        key_opts = [ "decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"] 
                                      }
                                    }  

}
module "key_vault" {
  source =  "../../"
  #source = "git::ssh://git@ssh.dev.azure.com/v3/eviCoreDev/Reusable%20Code/Azure-GoldenKeyVault?ref=v1.0.0"

  # replace these with your values
  resource_group_name             = var.resource_group_name
  name                            = var.name
  location                        = var.location

  initial_access_assignments      = var.initial_access_assignments
  enable_rbac_authorization       = var.enable_rbac_authorization
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment

  #Policy: Key vaults should have soft delete enabled
  soft_delete_retention           = var.soft_delete_retention
  
  #Policy: Key vaults should have deletion protection enabled
  enable_purge_protection = var.enable_purge_protection

  #Policy: Global Tags Policy
  required_tags                   = var.required_tags
  optional_tags                   = var.optional_tags

  #Policy: Azure Key Vault should disable public network access
  #Note: When public_network_access_enabled = false, Private Endpoints are required
  public_network_access           = var.public_network_access
 
  #Policy: Azure Key Vault should have firewall enabled
  #Policy: Configure key vaults to enable firewall
  #Policy: Key Vault should use a virtual network service endpoint
  virtual_network_subnet_ids      = var.virtual_network_subnet_ids  
  allowed_ip_rules                = var.allowed_ip_rules
  include_ado_cidrs               = var.include_ado_cidrs

  #Policy: Deploy - Configure diagnostic settings for Azure Key Vault to Log Analytics workspace
  #Policy: Deploy Diagnostic Settings for Key Vault to Event Hub
  #Policy: Deploy Diagnostic Settings for Key Vault to Log Analytics workspace
  keyvault_diagnostics_settings   = var.keyvault_diagnostics_settings
  
  #Policy: Configure Azure Key Vaults with private endpoints
  #Policy: Azure Key Vaults should use private link
  private_endpoint_subnet_id      = var.private_endpoint_subnet_id
  private_dns_zone_id             = var.private_dns_zone_id
   
  bypass_trusted_services         = true
  keyvault_keys                   = var.keyvault_keys
}

# Reference key vault built-in policies: https://learn.microsoft.com/en-us/azure/key-vault/policy-reference

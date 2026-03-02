module "key_vault" {
  source = "git::ssh://git@ssh.dev.azure.com/v3/eviCoreDev/Reusable%20Code/Azure-GoldenKeyVault?ref=v5.0.1"

  # replace these with your values
  resource_group_name             = var.resource_group_name
  name                            = local.keyvault_name
  location                        = var.location

  initial_access_assignments      = [
                                      {
                                        principal_id   = "self"
                                        roles          = ["Key Vault Administrator", "Key Vault Crypto Officer"]
                                        principal_type = "User" #Note: principal_type = User is only allowed for CCOE for testing purposes. Use ServicePrincipal or Group with RASS.
                                      }
                                    ]

  enable_rbac_authorization       = true


  #Policy: Key vaults should have soft delete enabled
  #soft_delete_retention           = var.soft_delete_retention
  
  #Policy: Key vaults should have deletion protection enabled
  #enable_purge_protection = var.enable_purge_protection

  #Policy: Global Tags Policy
  required_tags                   = var.required_tags
  optional_tags                   = var.optional_tags

  #Policy: Azure Key Vault should disable public network access
  #Note: When public_network_access_enabled = false, Private Endpoints are required
  public_network_access           = var.public_network_access_enabled
 
  #Policy: Azure Key Vault should have firewall enabled
  #Policy: Configure key vaults to enable firewall
  #Policy: Key Vault should use a virtual network service endpoint
  virtual_network_subnet_ids      = var.allowed_subnet_ids 
  allowed_ip_rules                = var.allowed_public_ips
  #include_ado_cidrs               = var.include_ado_cidrs

  #Policy: Deploy - Configure diagnostic settings for Azure Key Vault to Log Analytics workspace
  #Policy: Deploy Diagnostic Settings for Key Vault to Event Hub
  #Policy: Deploy Diagnostic Settings for Key Vault to Log Analytics workspace
  keyvault_diagnostics_settings   = [
  {
                                      name                           = "ToPd1-CloudSIEM"  
                                      #eviCore
                                      log_analytics_workspace_id     = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_security_siem/providers/Microsoft.OperationalInsights/workspaces/pd1-cloudsiem"
                                      #Cigna
                                      #log_analytics_workspace_id     = "/subscriptions/8f8658f7-1005-4817-879c-291df1ed1a7c/resourceGroups/tb-test-kv-tfm/providers/Microsoft.OperationalInsights/workspaces/cloudsiem"
                                      include_diagnostic_log_categories = true
                                      include_diagnostic_metric_categories = false  
                                  }
                                ]
  
  #Policy: Configure Azure Key Vaults with private endpoints
  #Policy: Azure Key Vaults should use private link
  private_endpoint_subnet_id      = var.pe_subnet_id
  #private_dns_zone_id             = var.private_dns_zone_id #For Cigna Tenant Only
   
  bypass_trusted_services         = true
  keyvault_keys                   = {
                                      "sa-cmk-key" = {
                                        #key_type = "RSA" # Overrideable
                                        #key_size = 4096  # Overrideable
                                        key_opts = [ "decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"] 
                                      }
                                    }  

}
module golden_storage_account_module {
  #depends_on = [azurerm_subnet.vnet_intg]
  # users must change to corresponding link
  source                                  = "git::ssh://git@ssh.dev.azure.com/v3/eviCoreDev/Reusable%20Code/Azure-GoldenStorage?ref=v1.1.0"
  name                                    = var.storage_name
  resource_group_name                     = var.rg_name
  location                                = var.location
  account_tier                            = var.account_tier
  account_kind                            = var.account_kind
  access_tier                             = var.access_tier
  identity_type                           = var.identity_type
  containers                              = var.containers

  #Policy: Geo-redundant storage should be enabled for Storage Accounts
  account_replication_type                = var.account_replication_type

  #Policy: Configure your Storage account public access to be disallowed
  allow_nested_items_to_be_public         = var.allow_nested_items_to_be_public

  #Policy: Storage accounts should disable public network access
  #Note: When public_network_access_enabled = false, Private Endpoints are required
  public_network_access_enabled           = var.public_network_access_enabled

  #Policy: Storage accounts should restrict network access using virtual network rules
  allowed_subnet_ids                      = var.allowed_subnet_ids #[azurerm_subnet.vnet_intg.id]

  #Policy: Global Tags Policy
  required_tags                                    = var.required_tags

  #Policy: Storage accounts should prevent shared key access 
  #Note: when share_access_key_enable = false, default_to_oauth_authentication will be forced to true
  shared_access_key_enabled               = var.shared_access_key_enabled
  default_to_oauth_authentication         = var.default_to_oauth_authentication

  #Policy: Storage accounts should have infrastructure encryption
  infrastructure_encryption_enabled       = var.infrastructure_encryption_enabled

  storage_diagnostics_settings            = var.storage_diagnostics_settings
  blob_diagnostics_settings               = var.blob_diagnostics_settings
  file_diagnostics_settings               = var.file_diagnostics_settings
  queue_diagnostics_settings              = var.queue_diagnostics_settings
  table_diagnostics_settings              = var.table_diagnostics_settings
  
}

#Add CMK using existing Key Vault
#See datasource.tf file for Key Vault Reference
#See role_assignment.tf for storage account to key vault role assignment (RBAC)

resource "azurerm_storage_account_customer_managed_key" "cmk" {
  depends_on = [module.golden_storage_account_module, azurerm_role_assignment.storage_cmk_role_assignment]
  storage_account_id = module.golden_storage_account_module.storage_account.id
  key_vault_id       = data.azurerm_key_vault.vault.id
  key_name           = "storagecmk" #Name of key created in Key Vault
}
/* 
    This module meets all current policies when using containers & blobs only.
    When using Storage File, all current policies will be met except for disabling Shared Access Keys.
    
    See README file in module root for further details 

*/


module golden_storage_account_module {
  #depends_on = [ module.key_vault ]

  # users must change to corresponding azure link
  source                                  = "../../"
  #source                                  = "git::ssh://git@ssh.dev.azure.com/v3/eviCoreDev/Reusable%20Code/Azure-GoldenStorage?ref=v2.0.1"
  name                                    = var.name
  resource_group_name                     = var.resource_group_name
  location                                = var.location
  account_tier                            = var.account_tier
  account_kind                            = var.account_kind
  access_tier                             = var.access_tier
  identity_type                           = var.identity_type
  #containers                              = var.containers #Add one or more containers
  #files                                   = var.files #Add one or more files
  #tables                                  = var.tables #Add one or more tables
  #queues                                  = var.queues #Add one or more queues


  #Policy: Secure transfer to storage accounts should be enabled
  # Module sets this to: True. No option to override

  #Policy: Storage accounts should have the specified minimum TLS version
  # Module sets this to: TL1_2. No option to override

  #Policy: Configure your Storage account public access to be disallowed
  # Module sets this to: False. No option to override

  #Policy: Storage accounts should prevent cross tenant object replication
  #cross_tenant_replication_enabled - Defaull = false

  #Policy: Geo-redundant storage should be enabled for Storage Accounts
  account_replication_type                = var.account_replication_type


  #Policy: Storage accounts should disable public network access
  #Note: When public_network_access_enabled = false, Private Endpoints are required
  public_network_access_enabled           = var.public_network_access_enabled

  #Policy: Storage accounts should restrict network access using virtual network rules
  allowed_subnet_ids                      = var.allowed_subnet_ids
  #Policy: Storage accounts should restrict network access
  allowed_public_ips                      = var.allowed_public_ips

  #Policy: Storage accounts should allow access from trusted Microsoft services
  network_rule_bypass                     = var.network_rule_bypass

  #Policy: Global Tags Policy
  required_tags                           = var.required_tags
  optional_tags                           = var.optional_tags
  required_data_tags                      = var.required_data_tags
  optional_data_tags                      = var.optional_data_tags

  #Policy: Storage accounts should have shared access signature (SAS) policies configured
  sas_expiration_period_policy            = var.sas_expiration_period_policy

  #Policy: Storage accounts should prevent shared key access 
  #Note: when share_access_key_enable = false, default_to_oauth_authentication will be forced to true
  shared_access_key_enabled               = var.shared_access_key_enabled
  default_to_oauth_authentication         = var.default_to_oauth_authentication

  #Policy: Storage accounts should have infrastructure encryption
  infrastructure_encryption_enabled       = var.infrastructure_encryption_enabled

  #Policy: Storage accounts should use customer-managed key for encryption
  cmk_keyvault                            = {
                                              create_new_keyvault         = true
                                              name                        = "cmk-testf110009-kv"
                                              private_endpoint_subnet_id  = var.pe_subnet_id #Add a private endpoint if required
                                              #cmk_key_name               = "storage-account-cmk-key-wipc"
                                              #allow_public_network_access = true
                                              #allowed_public_ips          = var.allowed_public_ips #Add allowed public IPs when public network access is enabled
                                              #allowed_subnet_ids          = var.allowed_subnet_ids #Add allowed subnets id when public network access is enabled
                                            }                                     

  #Policy: Configure diagnostic settings for Storage Accounts to Log Analytics workspace
  storage_diagnostics_settings            = var.storage_diagnostics_settings
  blob_diagnostics_settings               = var.blob_diagnostics_settings
  file_diagnostics_settings               = var.file_diagnostics_settings
  queue_diagnostics_settings              = var.queue_diagnostics_settings
  table_diagnostics_settings              = var.table_diagnostics_settings 



  #Policy: Configure Storage account to use a private link connection
  private_endpoints                       = var.private_endpoints #Add private endpoints to storage account
  pe_subnet_id                            = var.pe_subnet_id      #Add private endpoints to storage account

  #For testing purposes by ccoe team only.
  enable_ccoe_local_testing               = true #For RASS Testing.
}





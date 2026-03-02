resource_group_name         = "tb-test-kv-tfm"
name                        = "tb-gmtest-1033-kv"
location                    = "EastUS2" #eviCore
#location                    = "EastUS" #Cigna
public_network_access       = false
enable_rbac_authorization   = true

required_tags         = {
  AssetOwner             = "My Dev Team"
  CostCenter             = "61700200"
  ServiceNowAS           = "notassigned"
  ServiceNowBA           = "notassigned"
  SecurityReviewID       = "notassigned"
}

optional_tags = {
  BackupOwner   = "first.last@cigna.com"
  BusinessOwner = "notassigned"
  AppName       = "notassigned"
  ITSponsor     = "notassigned"
  Tier          = "2"
}

include_ado_cidrs = false

keyvault_diagnostics_settings = [
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

#eviCore Only
private_endpoint_subnet_id = "/subscriptions/75dbc8c6-6364-4eb1-91c1-3400a4010fb4/resourceGroups/dv1_rsg_eu2_infra_vnet/providers/Microsoft.Network/virtualNetworks/infra-vnet/subnets/infra-private_endpoints-subnet"

#Cigna Only
#private_dns_zone_id = "/subscriptions/8f8658f7-1005-4817-879c-291df1ed1a7c/resourceGroups/tb-private-dns-zone/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
#private_endpoint_subnet_id = "/subscriptions/8f8658f7-1005-4817-879c-291df1ed1a7c/resourceGroups/SPCreation-rg/providers/Microsoft.Network/virtualNetworks/SPCreation-dev-vnet/subnets/private_endpoint"

initial_access_assignments = [
    {
      principal_id   = "self"
      roles          = ["Key Vault Administrator", "Key Vault Crypto Officer"]
      principal_type = "User" #Note: principal_type = User is only allowed for CCOE for testing purposes. Use ServicePrincipal or Group with RASS.
    },
 #   {
 #     principal_id = "3072a91d-690f-4a31-9b2e-8c2417f1ac7e"
 #     roles        = ["Key Vault Crypto Service Encryption User"]
 #     principal_type = "ServicePrincipal"
 #   },
  #   {
 #     principal_id = "3072a91d-690f-4a31-9b2e-8c2417f1ac7e"
 #     roles        = ["Key Vault Crypto Service Encryption User"]
 #     principal_type = "Group"
 #   }
  ]

keyvault_keys = {
                  "storage-cmk" = {
                    #key_type = "RSA" # Overrideable
                    #key_size = 4096  # Overrideable
                    key_opts = [ "decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"] 
                  }
                }

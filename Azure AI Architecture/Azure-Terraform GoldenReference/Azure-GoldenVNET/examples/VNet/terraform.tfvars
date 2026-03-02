# For variable uses and values, please check README.md for details

application           = "myapp"
rg_name               = "tb_rsg_evicore_myapp_vnet"
location              = "eastus2"
vnetcidr              = ["100.127.0.0/27"]
allow_firewall_routes = false
subnets                                                 = {
    "private_endpoints"                                 = {
        address_prefixes                                = ["100.127.0.0/28"]
        private_endpoint_network_policies_enabled       = false
        service_endpoints                               = []
        managednsg                                      = false
        routetable_firewall                             = false
        }
    "appservice_integration"                            = {
        address_prefixes                                = ["100.127.0.16/28"]
        private_endpoint_network_policies_enabled       = true
        service_endpoints                               = ["Microsoft.Storage", "Microsoft.KeyVault"]
        managednsg                                      = false
        routetable_firewall                             = false
        routetable_microsoft                            = true
        delegation_name                                 = "appServiceDelegation"
        service_delegation_name                         = "Microsoft.Web/serverFarms"
        service_delegation_actions                      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
}

production            = true

required_tags                  = {
  CostCenter       = "61700200"
  AssetOwner       = "myapp_support_team_dl@cigna.com"
  ServiceNowBA     = "none"
  ServiceNowAS     = "none"
  SecurityReviewID = "none"
}

flow_storage_id = "/subscriptions/75dbc8c6-6364-4eb1-91c1-3400a4010fb4/resourceGroups/tb-rsg-storage-poc/providers/Microsoft.Storage/storageAccounts/tbteststrg1010"
monitor_log_storage_account_id = "/subscriptions/75dbc8c6-6364-4eb1-91c1-3400a4010fb4/resourceGroups/tb-rsg-storage-poc/providers/Microsoft.Storage/storageAccounts/tbteststrg1010"
# For variable uses and values, please check README.md for details

application = "udr"
rg_name     = "tb_rsg_evicore_myapp_vnet"
location    = "eastus2"
vnetcidr    = ["10.193.240.0/27"]

allow_databricks_routes = true // this flag is set to true because in the below subnet we added databricks
allow_ms_egress_routes = true  // this flag is set to true because in the below subnet we added appservice_integration
allow_apim_routes = false     // default is false
allow_firewall_routes = true  // default is true
allow_sqlmi_routes = false     // default is false

subnets = {
  "DataBricks" = {
    address_prefixes                          = ["10.193.240.0/28"]
    private_endpoint_network_policies_enabled = false
    service_endpoints                         = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.AzureCosmosDB", "Microsoft.KeyVault"]
    managednsg                                = true
    routetable_firewall                       = false
    routetable_databricks                     = true
  }
  "appservice_integration" = {
    address_prefixes                          = ["10.193.240.16/28"]
    private_endpoint_network_policies_enabled = true
    service_endpoints                         = ["Microsoft.Storage", "Microsoft.KeyVault"]
    managednsg                                = false
    routetable_firewall                       = true
    delegation_name                           = "appServiceDelegation"
    service_delegation_name                   = "Microsoft.Web/serverFarms"
    service_delegation_actions                = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
  }
 "sqlmi" = {
  address_prefixes                          = ["10.193.241.16/28"]
  private_endpoint_network_policies_enabled = true
  service_endpoints                         = ["Microsoft.Storage", "Microsoft.Sql"]
  managednsg                                = true
  routetable_firewall                       = false
  routetable_sqlmi                          = true
  delegation_name                           = "appServiceDelegation"
  service_delegation_name                   = "Microsoft.Web/serverFarms"
  service_delegation_actions                = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
 }
}

production = false

required_tags                  = {
  CostCenter       = "61700200"
  AssetOwner       = "My Dev Team"
  ServiceNowBA     = "none"
  ServiceNowAS     = "none"
  SecurityReviewID = "none"
}

flow_storage_id = "/subscriptions/aaaa1111-bbbb-cccc-dddd-eeee99999999/resourceGroups/myapp_rsg_eu2_terraform/providers/Microsoft.Storage/storageAccounts/dv1eu2myapptfstate"

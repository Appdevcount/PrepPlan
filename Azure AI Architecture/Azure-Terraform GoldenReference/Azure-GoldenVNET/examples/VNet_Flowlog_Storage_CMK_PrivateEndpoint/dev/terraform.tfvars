# For variable uses and values, please check README.md for details

#Comman variables
rg_name               = "tb_rsg_evicore_myapp_vnet"
location              = "eastus2"
environment           = "dev"
required_tags                  = {
  CostCenter             = "61700200"
  AssetOwner             = "myapp_support_team_dl@cigna.com"
  BusinessEntity         = "evicore"
  ComplianceDataCategory = "hipaa:pci"
  DataClassification     = "Proprietary"
  DataSubjectArea        = "client:customer"
  LineOfBusiness         = "commercial"
  ServiceNowBA           = "notassigned"
  ServiceNowAS           = "notassigned"
  SecurityReviewID       = "notassigned"
}

#Variables for VNet
application           = "myapp"
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

#Vaiables for Storage Account
storage_name                      = "vnetmonitorsa"
account_kind                      = "StorageV2"
account_tier                      = "Standard"
account_replication_type          = "GRS"
access_tier                       = "Hot"
shared_access_key_enabled         = true
default_to_oauth_authentication   = false
public_network_access_enabled     = true #In most cases, this can be set to false if storage account uses private endpoint
infrastructure_encryption_enabled = false
allowed_subnet_ids                = [
 "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_vnet_products/providers/Microsoft.Network/virtualNetworks/eu2_pd1_vnet_products/subnets/eu2_pd1_snet_products_devops_10.194.62.0_23"
]
allow_nested_items_to_be_public   = false
identity_type                     = "SystemAssigned"
containers = [
  {
    name        = "testcontainer-1"
    access_type = "private"
  }

]

storage_diagnostics_settings = [
  {
      name                           = "ToPd1-CloudSIEM"  
      log_analytics_workspace_id     = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_security_siem/providers/Microsoft.OperationalInsights/workspaces/pd1-cloudsiem"
      eventhub_authorization_rule_id = null
      eventhub_name                  = null
  }
]

blob_diagnostics_settings = [
  {
      name                           = "ToPd1-CloudSIEM"  
      log_analytics_workspace_id     = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_security_siem/providers/Microsoft.OperationalInsights/workspaces/pd1-cloudsiem"
      eventhub_authorization_rule_id = null
      eventhub_name                  = null
       
      #eventhub_authorization_rule_id = "/subscriptions/75dbc8c6-6364-4eb1-91c1-3400a4010fb4/resourceGroups/eh_cloudcoe_dev_storage_testing/providers/Microsoft.EventHub/namespaces/eh-ccoe-eventhub-diagnostics/authorizationRules/RootManageSharedAccessKey"
      #eventhub_name                  = "loganalytics-test" 
  }
]

file_diagnostics_settings = [
  {
      name                           = "ToPd1-CloudSIEM"  
      log_analytics_workspace_id     = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_security_siem/providers/Microsoft.OperationalInsights/workspaces/pd1-cloudsiem"
      eventhub_authorization_rule_id = null
      eventhub_name                  = null
  }
]
queue_diagnostics_settings = [
  {
      name                           = "ToPd1-CloudSIEM"  
      log_analytics_workspace_id     = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_security_siem/providers/Microsoft.OperationalInsights/workspaces/pd1-cloudsiem"
      eventhub_authorization_rule_id = null
      eventhub_name                  = null
  }
]
table_diagnostics_settings = [
  {
      name                           = "ToPd1-CloudSIEM"  
      log_analytics_workspace_id     = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_security_siem/providers/Microsoft.OperationalInsights/workspaces/pd1-cloudsiem"
      eventhub_authorization_rule_id = null
      eventhub_name                  = null
  }
]


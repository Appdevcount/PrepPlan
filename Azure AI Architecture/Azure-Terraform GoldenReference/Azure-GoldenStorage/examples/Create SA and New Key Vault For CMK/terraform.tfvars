resource_group_name               = "tb-test-storage-poc-test"
name                              = "test1000050tfstate"
location                          = "eastus2"
account_kind                      = "StorageV2"
account_tier                      = "Standard"
account_replication_type          = "GRS"
access_tier                       = "Hot"
shared_access_key_enabled         = true
default_to_oauth_authentication   = false
public_network_access_enabled     = false
infrastructure_encryption_enabled = false
identity_type                     = "SystemAssigned"
#allowed_public_ips               = []  See Default Values
#allowed_subnet_ids                = []
#allowed_subnet_ids               = [
# "/subscriptions/75dbc8c6-6364-4eb1-91c1-3400a4010fb4/resourceGroups/dv1_rsg_eu2_infra_vnet/providers/Microsoft.Network/virtualNetworks/infra-vnet/subnets/infra-private_endpoints-subnet"
#]


required_tags = {
  AssetOwner             = "troy.braman@evicore.com"
  CostCenter             = "61700200"
  SecurityReviewID       = "notassigned"
  ServiceNowAS           = "notassigned"
  ServiceNowBA           = "notassigned"
}

optional_tags = {
                  AppName       = "EP/UNX",
                  BackupOwner   = "troy.braman@evicore.com",
                  BusinessEntity = "evicore"
                  BusinessOwner = "troy.braman@evicore.com",
                  GroupEmail    = "imageone-releaseengineering@evicore.com"
                  #AppCategory   = "ccoe"
                  #AppTeam       = "ccoe"
                  #Tier          = "4"
                  P2P           = "RITM123456"
                  #P2P-Iteration = "1"
                  #LineOfBusiness = "healthServices"
                  DataSubjectArea = "it"
                  DataClassification = "confidential"
                  ComplianceDataCategory = "pii:hipaa"


}

required_data_tags = {
  BusinessEntity         = "none"
  ComplianceDataCategory = "none"
  DataClassification     = "internal"
  DataSubjectArea        = "it"
  LineOfBusiness         = "none"
}

containers = ["tfstate"]
/* files = [
 {
    name  = "testfileshare-1"
    quota = 30
  },
  {
    name  = "testfileshare-2"
    quota = 10    
  }
] */
#tables = ["testtable1", "testtable2"]
#queues = ["testqueue-1", "testqueue-2"]

storage_diagnostics_settings = [
  {
      name                           = "ToPd1-CloudSIEM"  
      log_analytics_workspace_id     = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_security_siem/providers/Microsoft.OperationalInsights/workspaces/pd1-cloudsiem"
  }
]

blob_diagnostics_settings = [
  {
      name                           = "ToPd1-CloudSIEM"  
      log_analytics_workspace_id     = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_security_siem/providers/Microsoft.OperationalInsights/workspaces/pd1-cloudsiem"
  }
]

file_diagnostics_settings = [
  {
      name                           = "ToPd1-CloudSIEM"  
      log_analytics_workspace_id     = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_security_siem/providers/Microsoft.OperationalInsights/workspaces/pd1-cloudsiem"
  }
]
queue_diagnostics_settings = [
  {
      name                           = "ToPd1-CloudSIEM"  
      log_analytics_workspace_id     = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_security_siem/providers/Microsoft.OperationalInsights/workspaces/pd1-cloudsiem"
  }
]
table_diagnostics_settings = [
  {
      name                           = "ToPd1-CloudSIEM"  
      log_analytics_workspace_id     = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_security_siem/providers/Microsoft.OperationalInsights/workspaces/pd1-cloudsiem"
  }
]


#private_endpoints = ["blob", "file", "table", "queue"]
private_endpoints = ["blob","web"]
pe_subnet_id      = "/subscriptions/75dbc8c6-6364-4eb1-91c1-3400a4010fb4/resourceGroups/dv1_rsg_eu2_infra_vnet/providers/Microsoft.Network/virtualNetworks/infra-vnet/subnets/infra-private_endpoints-subnet"



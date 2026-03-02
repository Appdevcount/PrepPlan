##########################################################
## Example name (eg. NewModule Geo-Redundant deployment ##
##########################################################

/* Create a functional example of a use-case that would consume your module -- create a single
   root module (main.tf) unless complexity of use-case warrants multiple .tf files             */

terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.23"
    }
  }
}

provider "azurerm" {
  features {}
}

#Prepare environment

  # Include resources / data sources required to support the example

#Deploy NewModule in primary and redundant locations, with synchronization enabled 
module "Azure-GoldenCosmosModule" {
  #source = "git::https://github.sys.cigna.com/cigna/Azure-GoldenNewModule.git?ref=v0.1.0"
  source = "../../"

  # Pass variables to module (avoid referencing a variables file, to provide maximum clarity of module usage within the example)
  resource_group_name               = "tb-cosmos-golden-module"
  prefix_name                       = "eh"
  location                          = "eastus2"
  location_abbr                     = "eu2"
  environment                       = "dv1"
  cosmos_account_name               = "web-intake"
  cosmos_database_name              = "database1"
  enable_automatic_failover         = true
  enable_free_tier                  = false
  enable_multiple_write_locations   = false

  
  # Policy: Azure Cosmos DB should disable public network access
  # Policy: Configure CosmosDB accounts to disable public network access
  public_network_access_enabled     = true
  
  # Policy: Azure Cosmos DB accounts should have firewall rules
  vnet_subnets                      = ["/subscriptions/ed7f55f8-8333-41d1-b014-dcbf053db018/resourceGroups/dv1_rsg_eu2_vnet_products/providers/Microsoft.Network/virtualNetworks/eu2_dv1_vnet_products/subnets/eu2_dv1_snet_products_devops_10.193.228.0_24"]
  allowed_ip_range_filter           = "199.204.156.0/22,198.27.9.0/24"
  enable_azure_portal_access        = true

  # Policy: Enable logging by category group for Azure Cosmos DB (microsoft.documentdb/databaseaccounts) to Log Analytics
  cosmosdb_diagnostics_settings     = [{
                                         name                           = "ToPd1-CloudSIEM"  
                                         log_analytics_workspace_id     = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_security_siem/providers/Microsoft.OperationalInsights/workspaces/pd1-cloudsiem"
                                         #storage_id = "/subscriptions/75dbc8c6-6364-4eb1-91c1-3400a4010fb4/resourceGroups/tb-rsg-storage-poc/providers/Microsoft.Storage/storageAccounts/storageacapoc43210"
                                         include_diagnostic_metric_categories = true  
                                        }
                                      ]
  enable_default_alerting           = true
  alarm_funnel_id                   = "/subscriptions/4291F6CB-6ACB-4857-8D9A-3510DF28CE1D/resourceGroups/AlarmFunnel-rg/providers/microsoft.insights/actionGroups/AlarmFunnel-ag"
  
  # Policy: Azure Cosmos DB throughput should be limited
  db_container_configurations = {
                                  "CaseRouting" = {
                                    default_ttl               = -1
                                    throughput                = 400
                                    partition_key_path        = "OrganizationKey"
                                    included_paths            = ["/*"]                            
                                  },
                                  "WorkflowException" = {
                                    default_ttl               = 7776000
                                    auto_scale_max_throughput = 1000
                                    partition_key_path        = "ProblemStatus"
                                    partition_key_version     = 2
                                    included_paths            = ["/*"]
                                    excluded_paths            = ["/status/?"]
                                    composite_indexes         = [[
                                      {path = "/status"
                                       order = "ascending"},
                                      {path = "/errorcode"
                                       order = "ascending"}
                                    ]]
                                  },
                                  "UserPreference" = {
                                    default_ttl               = -1
                                    throughput                = 600  
                                    #auto_scale_max_throughput = 4000                                 
                                    partition_key_path        = "UserName"
                                    included_paths           = ["/*", "/test/?"]
                                    indexing_mode             = "consistent"                                    
                                  },
                                  "OCRDocument" = {
                                    default_ttl               = -1
                                    auto_scale_max_throughput = 4000
                                    partition_key_path        = "ServiceRequestId"
                                    included_paths            = ["/*"]                        
                                    unique_keys               = ["/definition/idlong", "/definition/idshort"]
                                  }
                                }
  # Policy: Tag Policy                              
  required_tags         = {
                            AssetOwner           = "troy.braman@evicore.com"
                            CostCenter           = "61700200"
                            SecurityReviewID     = "notassigned"
                            ServiceNowAS         = "notassigned"
                            ServiceNowBA         = "notassigned"
                          }
  # Policy: Tag Policy                            
  required_data_tags    = {
                            DataSubjectArea        = "it"
                            ComplianceDataCategory = "none"
                            DataClassification     = "internal"
                            BusinessEntity         = "evicore"
                            LineOfBusiness         = "healthServices"
                          }

  failover_geo_locations = [
                             {
                              location = "eastus2",
                              failover_priority = 0,
                              zone_redundant    = false
                             }, 
                             {
                              location = "centralus",
                              failover_priority = 1,
                              zone_redundant    = false
                             }
                          ]
  serverless                 = false    

  # Policy: Configure CosmosDB accounts with private endpoints
  private_endpoint_subnet_id = "/subscriptions/75dbc8c6-6364-4eb1-91c1-3400a4010fb4/resourceGroups/dv1_rsg_eu2_infra_vnet/providers/Microsoft.Network/virtualNetworks/infra-vnet/subnets/infra-private_endpoints-subnet"

  # Policy: Azure Cosmos DB accounts should use customer-managed keys to encrypt data at rest
  # See CMK Configuration Examples
  #identity_type               = "UserAssigned"
  #enable_customer_managed_key = true
  #user_identities             = [azurerm_user_assigned_identity.uai.id]
  #keyvault_encryption_key_id  = data.azurerm_key_vault_key.cmk.versionless_id # Use the versionless id to enable Auto-Key Rotation                   
                      
}
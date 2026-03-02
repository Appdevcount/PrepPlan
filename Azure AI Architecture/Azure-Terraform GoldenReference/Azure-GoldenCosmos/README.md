> Refer to https://confluence.sys.cigna.com/display/CLOUD/Terraform+Module+Standards for Terraform module development standards and guidelines.

# Module Name

## Overview

> This Terraform module will deploy a Cigna\eviCore standard NewModule. It creates the following resources:

- Cosmos Account
- Cosmos Database
- One or more Cosmos Containers
- Diagnostic Settings
- Alerts
- Private Endpoint

## Dependencies

> Include specific dependencies that must be met for the module to deploy / function properly

- DocumentDB Resource Provider must be registered in the subscription
- Terraform version 0.13 or newer is required for this module
- A resource group must exist
- Customer Managed Key requires existing Key Vault and User Managed Identity
- 

## Inputs

### REQUIRED:

> Include all required variables here (variables that do not include default values). Pick the appropriate required_tags line for data or no data tagging.

| Name                          | Description                                                                                                                                                                                             | Type                                                                                                                                                                                                                                                             |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| resource_group_name           | Resource group to deploy into                                                                                                                                                                           | string                                                                                                                                                                                                                                                           |
| cosmos_account_name           | Desired <application/resource> name                                                                                                                                                                     | string                                                                                                                                                                                                                                                           |
| required_tags                 | Required Cigna tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)                                                                                          | object({AssetOwner = string, CostCenter = string, ServiceNowBA = string, ServiceNowAS = string, SecurityReviewID = string})                                                                                                                                      |
| required_data_tags            | Required Cigna tags with data tagging (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)                                                                        | object({ DataSubjectArea = string, ComplianceDataCategory = string, DataClassification = string, BusinessEntity = string, LineOfBusiness = string})                                                                                                              |
| environment                   | The name of the environment for the resource. Such as dv1, in1, pd1                                                                                                                                     | string                                                                                                                                                                                                                                                           |
| location                      | Region to deploy to                                                                                                                                                                                     | string                                                                                                                                                                                                                                                           |
| cosmos_database_name          | The name of Cosmos Database                                                                                                                                                                             | string                                                                                                                                                                                                                                                           |
| identity_type                 | If using CMK otherwise Optional: The Type of Managed Identity assigned to this Cosmos account. Possible values are SystemAssigned, UserAssigned and SystemAssigned, UserAssigned.                       | string                                                                                                                                                                                                                                                           |
| user_identities               | If using CMK otherwise Optional: Specifies a list of User Assigned Managed Identity IDs to be assigned to this Cosmos Account.                                                                          | list(string)                                                                                                                                                                                                                                                     |
| keyvault_encryption_key_id    | If using CMK otherwise Optional: Name of Key Vault encryption key name                                                                                                                                  | string                                                                                                                                                                                                                                                           |
| failover_geo_locations        | Specifies a geo_location resource, used to define where data should be replicated with the failover_priority 0 specifying the primary location.                                                         | list(object({location = string  failover_priority = number Zone_redundant = bool })                                                                                                                                                                              |
| vnet_subnets                  | If no IP Range filters used otherwise Optional: A list of vnets to integrate                                                                                                                            | list(string)                                                                                                                                                                                                                                                     |
| allowed_ip_range_filter       | If no VNet Integration subnets used otherwise Optional. List of public IP or IP ranges in CIDR Format.                                                                                                  | string                                                                                                                                                                                                                                                           |
| db_container_configurations   | Used for creating one or more Containers.                                                                                                                                                               | list(string)                                                                                                                                                                                                                                                     |
| cosmosdb_diagnostics_settings | List of diagnostic settings                                                                                                                                                                             | list(object({ name = string log_analytics_workspace_id = optional(string,null) storage_id = optional(string, null) eventhub_authorization_rule_id = optional(string, null) eventhub_name = optional(string, null) include_diagnostic_metric_categories = bool }) |
| alert_environment             | If enabling default alerts otherwise Optional. The name of the environment for the resource. Such as SANDBOX, DEV, PROD. Reference: https://confluence.sys.cigna.com/display/CLOUD/Alarm+Funnel+-+Azure | string                                                                                                                                                                                                                                                           |
| alarm_funnel_id               | If enabling default alerts otherwise Optional.: Alert Funnel Action Group Resource Id                                                                                                                   | string                                                                                                                                                                                                                                                           |
| private_dns_zone_id           | Required if enabling Private Endpoints only for Cigna tenant.                                                                                                                                           | string                                                                                                                                                                                                                                                           |
|                               |                                                                                                                                                                                                         |                                                                                                                                                                                                                                                                  |

### OPTIONAL:

> Include all configuration variables that are not required, along with default value

| Name                               | Description                                                                                                                                                                                                                                                       | Type         |  
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ | 
| location_abbr                      | Region to deploy to in abbreviated format. eu, eu2, cus etc.                                                                                                                                                                                                      | string       | 
| optional_tags                      | Standard tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)                                                                                                                                                          | map(string)  | 
| optional_data_tags                 | Tags for data (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)                                                                                                                                                          | string       | 
| prefix_name                        | Can be used for any resource name.                                                                                                                                                                                                                                | object       | 
| suffix_name                        | Can be used for any resource name. Reference: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations                                                                                                  | object       | 
| enable_customer_managed_key        | Use Customer Managed Key for data at rest encryption                                                                                                                                                                                                              | bool         | 
| kind                               | Specifies the Kind of CosmosDB to create - possible values are GlobalDocumentDB, MongoDB and Parse. Defaults to: GlobalDocumentDB                                                                                                                                 | string       | 
| enable_free_tier                   | Enable the Free Tier pricing option for this Cosmos DB account.                                                                                                                                                                                                   | bool         | 
| enable_automatic_failover          | Enable automatic failover for this Cosmos DB account.                                                                                                                                                                                                             | bool         | 
| enable_multiple_write_locations    | Enable multiple write locations for this Cosmos DB account.                                                                                                                                                                                                       | bool         | 
| serverless                         | Flag to configure the account for serverless throughput.                                                                                                                                                                                                          | bool         | 
| capabilities                       | Configures the capabilities to be enabled for this Cosmos DB account.                                                                                                                                                                                             | list(object) | 
| enable_continuous_backup           | Flag to use Continuous Backup Policy                                                                                                                                                                                                                              | bool         | 
| backup_policy                      | Backup Policy. Type must be Periodic or Continuous                                                                                                                                                                                                                | object       | 
| consistency_level                  | Defines the consistency level for this CosmosDB account.                                                                                                                                                                                                          | string       | 
| max_interval_in_seconds            | When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated. Accepted range for this value is 5 - 86400 (1 day). Defaults to 5. Required when consistency_level is set to BoundedStaleness. | number       | 
| max_staleness_prefix               | When used with the Bounded Staleness consistency level, this value represents the number of stale requests tolerated. Accepted range for this value is 10 - 2147483647. Defaults to 100. Required when consistency_level is set to BoundedStaleness.              | number       | 
| public_network_access_enabled      | Whether or not public network access is allowed. Defaults to true but will require firewall settings.                                                                                                                                                             | bool         | 
| enable_azure_portal_access         | To enable portal access. https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-configure-firewall#allow-requests-from-the-azure-portal                                                                                                                         | string       | 
| auto_scale_max_throughput          | The maximum throughput for autoscaling. Must be increments of 1000.                                                                                                                                                                                               | number       | 
| enable_default_alerting            | Enable default alerts. Defaut = true                                                                                                                                                                                                                              | bool         | 
| private_endpoint_subnet_id         | The subnet id used for the Private Endpoint IPs                                                                                                                                                                                                                   | string       | 
| access_key_metadata_writes_enabled | Enables write operations on metadata resources (databases, containers, throughput) via account keys. https://learn.microsoft.com/en-us/azure/cosmos-db/audit-control-plane-logs#disable-key-based-metadata-write-access                                           | bool         | 

### Outputs

> Include all outputs returned by your module

| Name                    | Description                | Sensitive |
| ----------------------- | -------------------------- | --------- |
| cosmos_account_endpoint | Cosmos URI                 | false     |
| cosmos_account_id       | Cosmos Account Resource ID | false     |
| cosmos_account_name     | Cosmos Account Name        | false     |
| cosmos_database_name    | Cosmos Database Name       | false     |
| connection_strings      | Comsos Connections strings | true      |
| primary_key             | Primary key Access Key     | true      |
| secondary_key           | Secondary key Access Key   | true      |

## Usage

> See "Primary Use Case Example"

## Submodules

> List any modules that are called by your module

- n/a

> ## Additional Information
>
> n/a

## Links

- Tag Requirements: https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements
- Portal Access Firewall Setting: https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-configure-firewall#allow-requests-from-the-azure-portal
- Cosmos Alerts FMEA: https://confluence.sys.cigna.com/pages/viewpage.action?pageId=332060441
- Alarm Funnel: https://confluence.sys.cigna.com/display/CLOUD/Alarm+Funnel+-+Azure

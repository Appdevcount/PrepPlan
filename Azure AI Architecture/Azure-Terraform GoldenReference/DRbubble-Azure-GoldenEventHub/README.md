# Azure Golden Event Hub

## Overview
This Terraform module creates:
  - Event Hub Namespace
  - DR Namespace if DR region is specified
  - Event Hubs in namespace
  - Access control rules
  - Private Endpoints
  - Additional monitoring if location is specified

## Dependencies
- Event Hub Resource Provider must be registered in the subscription
- If Private Endpoint will be created in a different subscription, the Event Hub Resource Provider must be registered in that subscription as well
- Terraform version 0.13 or newer is required for this module to work.
- A resource group must exist
- A Virtual network and subnet is required for the Private Endpoint with PE rules enabled
- If a DR site is specified, a virtual network and subnet are required for the DR Private Endpoint with PE rules enabled
- If additional monitoring (beyond that specified by Azure Policy) is desired, a Log Analytics Workspace, Storage Account, or Event Hub is required
- If deploying to a dedicated cluster, Customer Managed Keys (CMK) will need to be configured after the namespace has been deployed, and before any event hubs have been added. This will require deploying in three steps. This module will be updated when a Terraform supported way is available to deploy the namespace with CMK. As a workaround, a Powershell script can be used to enable CMK on a namespace in a dedicated cluster.

## Inputs

### REQUIRED:
| Name                 | Description                     | Type   | 
|----------------------|---------------------------------|--------|
| resource_group_name | Resource group to deploy into   | string |
| name                | Desired Namespace name          | string |
| event_hubs          | Describes the event hubs to create in the namespace | <pre>map(object({<br>  partition_count = number<br>  message_retention  = number<br>  consumer_groups    = list(string)<br>  access_policies    = map(object({<br>    send    = bool<br>    listen  = bool<br>    }))<br>  })) |
| required_tags     | Required Cigna tags AssetOwner, CostCenter, ServiceNowBA, ServiceNowAS, SecurityReviewID (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0) | map(string) |

### OPTIONAL:
| Name                 | Description                     | Type   | Default  |
|----------------------|---------------------------------|--------|----------|
| location             | Region to deploy in             | string | "EastUS" |
| dr_location          | Region for Geo-DR. If set and SKU is standard, Geo-DR will be enabled | string | null |
| pe_resource_group_name | Resource group where PE shold be created, if different than resource group for namespace | string | null |
| pe_subnet_id         | ID of subnet where private endpoint should attach | string  | null |
| dedicated_cluster_id | If using a dedicated Event Hub cluster, ID of that cluster  | string    | null |
| sku                  | SKU (Account Tier) for Event Hub Namespace -- Standard or Basic (not recommended for production) | string | "Standard" |
| capacity             | Initial TU capacity (does not apply to Dedicated clusters) -- must be 1-20 | number | 1 |
| namespace_shared_access_policies | Shared access policies to create for the Event Hub namespace -- only create if the application cannot support AAD integrated access | <pre>map(object({<br>  send    = bool<br>  listen  = bool<br>})) | null |
| allowed_subnet_ids   | List of subnet IDs allowed to access the Event Hub namespace | list(string) | [] |
| allowed_ip_ranges    | List of allowed IP subnets for Event Hub namespace   | list(string) | [] |
| pe_dr_resource_group_name | Resource group where DR PE shold be created, if different than resource group for namespace | string | null |
| pe_dr_subnet_id      | ID of subnet where private endpoint should attach    | string | null |
| dr_dedicated_cluster_id | If using a dedicated DR Event Hub cluster, ID of that cluster | string | null |
| logging_enabled      | Set to true if additional logging should be enabled - a log destination must be provided if true | bool    | false |
| log_storage_account_id | ID of Storage Account to use for diagnostic data destination | string | null |
| log_analytics_workspace_id | ID of Log Analytics Workspace for diagnostic data destination    | string | null |
| log_eventhub_namespace_authorization_rule_id | Namespace rule to use for streaming diagnostic data to Event Hub as destination | string | null |
| log_eventhub_name    | Name of Event Hub to stream diagnostic data -- leave null to accept default of creating an event hub for each diagnostic category | string | null |
| optional_tags | Additional standard Cigna tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements)    | map(string) | {} |


### OVERRIDE:<br>
*The default value for these variables should be accepted in production environments, these are provided only to accommodate dev/test or unanticipated corner cases*

| Name                 | Description                     | Type   | Default  |
|----------------------|---------------------------------|--------|----------|
| zone_redundant       | Zone redundancy disabled if set to false. Zone redundancy raises applicatoin resiliancy, with no added cost, so should normally be enabled. | bool | true |
| auto_inflate_enabled | Auto-inflation disabled if set to false. Auto inflate helps avoid performance issues if workload needs change, or are initially underestimated. Application should be monitored to avoid potential cost over-runs created by unexpected auto-inflation. Manual deflation is required if workload needs decrease. | bool | true |
| maximum_throughput_units | Maximum TUs namespace can inflate to, must be 1-20. Should be set to max in production to avoid potential performance bottlenecks. Application should be monitored to avoid potential cost over-runs created by auto-inflation that was unexpected / out of design specifications. | number | 20 |
| trusted_service_access_enabled | Enable trusted Microsoft services to bypass firewall rules (e.g. allow these services). Event Hubs will not work properly if it cannot access other Microsoft services it relies on, so this should typically be enabled. | bool |  true |
| private_endpoints    | Private endpoints are a typical Cigna requirement. This override is provided for corner cases where a private endpoint is not required | bool | true |

## Outputs

| Name    | Description               | Sensitive |
|---------|---------------------------|-----------|
| ns_name | Name of namespace         | false     |
| ns_id   | Identity of namespace | false |
| ns_identity| Identity of namespace service principal created, as a map of {principal_id = "xxxx", tenant_id = "xxxx", type = "SystemAssigned" | true |
| RootManageSharedAccessKey | Attributes for default RootManageSharedAccessKey of namespace, as a map of {default_primary_connection_string = "xxxx", "default_primary_connection_string_alias" = "xxxx", default_primary_key = "xxxx"} | true |
| eventhub_namespace_authorization_rule_id | ID of shared access rules created for namespace as list of IDs | false | 
| private_endpoint_id | Identity and IP of private endpoint as map of {id = "xxxx", ip = "xxx.xxx.xxx.xxx"} | false |
| drns_name | Name of DR namespace | false |
| drns_id | Identity of DR namespace | false |
| drns_identity | Identity of DR namespace service principal created, as a map of {principal_id = "xxxx", tenant_id = "xxxx", type = "SystemAssigned" | true |
| drprivate_endpoint_id | Identity and IP of DR private endpoint as map of {id = "xxxx", ip = "xxx.xxx.xxx.xxx"} | false |


## Usage

    module "Azure-GoldenEventHub-TC3" {source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenEventHub.git?ref=Initial_Release"

      name                        = "<namespace name>"
      location                    = "<region>"
      resource_group_name         = "<resource group>"
      pe_subnet_id                = "<ID of subnet for Private Endpoint>"
      dr_location                 = "<DR region>"
      pe_dr_subnet_id             = "<ID of subnet for Private Endpoint>"
      allowed_subnet_ids          = ["<ID of subnet to allow>", "<...>", ...]
      allowed_ip_ranges           = ["<CIDR 1>","<...>",...]
      logging_enabled             = true
      log_analytics_workspace_id  = "ID of LAW"

      namespace_shared_access_policies = {
        <policy name> = {
          send                    = true
          listen                  = false
        }
      }

      event_hubs = {
        <Hub 1 name> = {
          partition_count           = ##
          message_retention         = #
          consumer_groups           = ["CG 1","<...>",...]
          access_policies = {
            <Policy 1 name> = {
              send                  = true
              listen                = false
            },
            <Policy 2 name> = {
              send                  = true
              listen                = false
            },
            <...>
          }
        },
        <Hub 2 name> = {
          <...>
        },
        ...

      required_tags = {
        <tag name>                = <tag value>
        <...>
      }
    }

## Submodules
- n/a

## Links
- Service Page https://confluence.sys.cigna.com/display/CLOUD/Event+Hubs
- Examples https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenEventHub/examples/

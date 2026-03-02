# Azure-GoldenVNET

## Overview

This Terraform module creates the following resources:

- Virtual Network
- Subnets
- Network Security Groups
- Flow Logs (Optional)
  - Collect 'wire' traffic logs
  - Only works for virtual machines
  - Data is not easy to analyze
  - Requires a target storage account and log analytics workspace
- Monitoring Diagnostics
  - Required when using flow logs
- VNet Link to Private DNS Zone (Optional)

## Dependencies

- You must have an assigned IP block for any subnets that will be routable
- Terraform version 0.13 or newer is required for this module
- A resource group must exist

## Terraform Module usage example:

[./examples](./examples)

## Network diagram

![Design](/goldenvnet.drawio.png)

## Inputs

| Name                           | Description                                                                                               | Type            | Default           | Required |
| ------------------------------ | --------------------------------------------------------------------------------------------------------- | --------------- | ----------------- | :------: |
| application                    | The naming prefix used for all resources.                                                                 | `string`        | null              |   yes    |
| resource_group_name                        | The resource group to which all the network resources should be added.                                    | `string`        | `null`            |   yes    |
| location                       | Region to deploy to.                                                                                      | `string`        | `eastus2`         |   yes    |
| vnetcidr                       | The CIDR of the routable VNET.                                                                            | `string`        | `null`            |   yes    |
| subnets                        | Map of subnets, including address space, service endpoints, and private link policies                     | `map(object)`   | `null`            |   yes    |
| production                     | Boolean                                                                                                   | `bool`          | false             |   yes    |
| required_tags                  | Required tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+v2.0). | `object`        | `null`            |   yes    |
| enable_flow_logs               | Boolean indicating if flow logs should be enabled.                                                        | `bool`          | false             |   yes    |
| flow_log_storage_account_id    | The id for the storage account to which flow logs should be sent.                                         | `string`        | `null`            |    no    |
| monitor_log_storage_account_id | The id for the network monitor storage account, can be same as above or may be unique                     | `string`        | `null`            |    no    |
| user_defined_tags              | Optional standard tags                                                                                    | `map(string)`   | `null`            |    no    |
| dns_servers                    | List of IP addresses to use for DNS servers, if required, instead of using Azure DNS.                     | `map        `   | `null`            |    no    |
| dns_zone_name                  | Name of private dns zone to link VNet to.                                                                 | `string`        | `null`            |    no    |
| dns_zone_rg                    | Resource group that owns `var.dns_zone_name` dns zone.                                                    | `string`        | `null`            |    no    |
| nonRoutableSubnets             | Map of subnets.                                                                                           | `list(string)`  | `null`            |    no    |
| nonroutablevnetcidr            | The CIDR of the nonroutable VNET. Must be 100.126.0.0/16 or 100.127.0.0/16.                               | `list(string)`  | ["100.126.0.0/16"]|    no    |
| enable_nonroutable_peering     | Peers the routable and nonroutable vnets                                                                  | `bool`          | false             |    no    |
| firewall_ip_address            | IP addresses to use for Azure Firewall                                                                    | `map`           | see terraform code|    no    |
| location_abrv                  | Optional. The name of the location for the resource, such as eu, eu2, cus. To be used in VNET name)       | `string`        | ""                |    no    |
| environment                    | Optional. The name of the environment for the resource, such as dev, test, prod. To be used in VNET name) | `string`        | ""                |    no    |
| enable_diagnostics             | Include diagnostic for routable and nonroutable vnets                                                     | `bool`          | false             |    no    |
| vnet_suffix_name               | Optional: Suffix Name for VNet.                                                                           | `string`        | -vnet             |    no    |
| subnet_suffix_name             | Optional: Suffix Name for Subnets.                                                                        | `string`        | -subnet           |    no    |
| nonroutable_vnet_suffix_name   | Optional: Suffix Name for NonRoutable Subnets.                                                            | `string`        | -nonroutable-subnet|    no    |
| nsg_suffix_name                | Optional: Suffix Name for NSG.                                                                            | `string`        | -nsg              |    no    |
| nsg_nonroutable_suffix_name    | Optional: Suffix Name for NonRoutable NSG.                                                                | `string`        | -nonroutable-nsg  |    no    |
| flow_log_suffix_name           | Optional: Suffix Name for flow logs.                                                                      | `string`        |-flow-log          |    no    |
| nonroutable_flow_log_suffix_name | Optional: Suffix Name for nonroutable flow logs.                                                        | `string`        |-nonroutable-flow-log|    no    |
| routetable_suffix_name         | Optional: Suffix Name for all route table.                                                                | `string`        | -default-internet-rt |    no    |
| routetable_databricks_suffix_name | Optional: Suffix Name for databricks route table.                                                      | `string`        | -databricks       |    no    |
| routetable_apim_suffix_name     | Optional: Suffix Name for apim route table.                                                              | `string`        | -apim             |    no    |
|routetable_microsoft_suffix_name | Optional: Suffix Name for microsoft route table.                                                         | `string`        | -microsoft        |    no    |



## Outputs

| Name                              | Description                      |
| --------------------------------- | -------------------------------- |
| current_subscription_display_name | Name of the current subcription. |
| sg_id                             | ID of network security group.    |
| subnets                           | List of subnets.                 |
| vnet                              | Name of VNet.                    |
| subnets_nonroutable               | List of subnets.                 |
| vnet_nonroutable                  | Name of VNet.                    |
| nonroutable_sg_id                 | ID of network security group.    |

## Network Security Group (NSG) Considerations

- Security standards require that an NSG be attached to each of your subnets.
- This is an audit item for Path to Production.
- By default, this module will take care of this for you.
- There are use cases that require disabling this behavior, as subnets can only be attached to a single NSG.
- By default 'var.subnets.managednsg' is set to *false*. Setting it to *true* will allow creation of your own NSG, or allow another Azure service to do so.
- These services are known to install their own NSGs:
  - SQL Managed Instance
  - Databricks
  - Kubernetes Service (AKS)
- Additionally, these services expect you to create your own NSG with specific rules to function properly:
  - Application Gateway
  - API Manager (APIM)
  - App Service Environment (ASE)
- Your application may also have security requirements to only allow traffic from specific internal sources, in which case you will also need to create your own NSG.

## Azure Firewall and Route Tables

- By default this module will route traffic destined for the Internet through an Azure Firewall.
- The firewall allows standard ports (https) outbound. If your application requires other ports to be opened, submit a detailed request in SNOW to the eviCore Cloud team.
- This is important to ensure your workload will function properly after the upcoming Data Center migrations.
- other services like databricks, apim, ase, sql managed instance ... require different route to different destination, to make sure those services work set the 'var.routetable_firewall' to false and based on the serive type
- set the flag to true, currently in this module there are 4 more identified special route table, as follow:

1. databricks route table, for databricks subnets, to assign subnet to this route table set routetable_databricks to true, and routetable_firewall to false.
2. apim route table, for for apim subnets, to assign subnet to this route table set routetable_apim to true, and routetable_firewall to false..
3. microsoft route table, some services require its traffic to be routed directly to microsoft internet like ase, and application gateway, to assign subnet to this route table set routetable_microsoft to true, and routetable_firewall to false.
4. sqlmi route table and default sqlmi nsg rules can be added by enableing flag isroutetable_sqlmi to true and routetable_firewall to false. Default is false.

- At least one service in Azure, SQL Managed Instance, is known to require its own route table, which not identified in this module to make sure this service work set routetable_firewall to false.
  for more details refer to https://evicorehealthcare.atlassian.net/wiki/spaces/~131354132/pages/770015359/Networking+Vnet+NSG+Route+Tables+etc.#Route-Tables-for-different-resources%27-subnets.

## To-do work items for this module

* Is this the right resource group structure?
* Optional rulesets for NSGs
* Is this modular enough?

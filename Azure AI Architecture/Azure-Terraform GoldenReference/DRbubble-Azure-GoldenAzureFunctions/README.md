# Azure-GoldenKeyVault

## Overview

This Terraform module will deploy a Cigna standard Azure Function as well as the resources necessary for insights, management, and update deployments. It will also optionally create Azure Function diagnostics logs and metrics.

Access for the Source Code Storage module is managed through whitelisted public IP addresses and subnets and can be configured within the module's variables.

This module creates the following resources:

  - Application Insight
  - Azure Function App
  - Monitor Diagnostic Setting (Optional)
  - Storage BLOB
  - Storage Container

## Prerequisites

This module assumes that you have your artifact, artifact path, and arfifact root available and properly configured for source code storage.

## Tags

The following tags are required. Please do not forget to specify the following values:

* CostCenter
* AssetOwner
* SecurityReviewID
* ServiceNowAS
* ServiceNowBA

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name to use as reference for the components created by this module | `string` | n/a | yes |
| resource\_group\_name | Name of the existing resource group that will house the components created by this module. | `string` | n/a | yes |
| location | Azure location to deploy resources into. | `string` | n/a | yes |
| artifact\_root | Artifact root location. | `string` | `https://artifactory.express-scripts.com/artifactory` | yes |
| artifact\_path | Directory path for your target artifact. | `string` | n/a | yes |
| artifact | Name of the target artifact. | `string` | n/a | yes |
| app\_service\_plan\_id | Id of the app service plan that will be used by this function. | `string` | n/a | yes |
| os\_type | The OS type of the container resource. | `string` | 'windows' | yes |
| app\_settings | Map of settings to be passed to function for environment configuration. | `map(string)` | '{}' | yes |
| allowed\_subnet\_ids | Subnet Ids for networks that require access to this storage account. | `list(string)` | null | yes |
| optional\_tags | Tags that are optional per the version 2 tagging standards. | `object` | n/a | yes |
| optional\_data\_tags | Tags that are optional per the version 2 tagging standards for data at rest. | `object` | n/a | yes |
| required\_tags | Tags that are required per the version 2 tagging standards. | `object` | n/a | yes |
| required\_data\_tags | Tags that are required per the version 2 tagging standards for data at rest. | `object` | n/a | yes |
| sas\_start\_date | SAS key start date for connection to function code storage account | `string` | `2020-10-01` | yes |
| sas\_expiry\_date | SAS key expiration data for connection to function code storage account. | `string` | `2025-09-30` | yes |
| monitor\_log\_storage\_account\_id | Id for shared monitoring storage account ID. | `string` | n/a | yes
| worker\_process\_count | Number of process threads to allocate for the function on each worker. | `string` | '1' | yes
| function\_runtime | Runtime of the functions in the function app. | `string` | n/a | yes |
| application\_type | Application Type for Application Insights. | `string` | n/a | yes |
| source\_code\_storage\_source | Git repo for source code. | `string` | n/a | yes |
| allowed\_public\_ids | public IPs that require access to this storage account. | `list(string)` | null | yes |

## Outputs

| Name | Description |
|------|-------------|
| function | Name of the Azure function application. |
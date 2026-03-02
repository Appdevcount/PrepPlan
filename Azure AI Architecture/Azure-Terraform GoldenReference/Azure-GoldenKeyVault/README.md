# Azure-GoldenKeyVault (5.0.1)

## Overview

ALWAYS RUN A TERRAFORM PLAN TO VERIFY IF A DESTROY WILL TAKE PLACE ESPECIALLY IF YOUR PIPELINE USES AUTO APPROVE ON A TERRAFORM APPLY WITHOUT FIRST VERIFING A TERRAFORM PLAN.

This Terraform module will deploy a Cigna\eviCore standard Key Vault and the necessary private endpoint for connecting from within a vnet.

This module supports ***RBAC*** and ***Vault Access Policy*** permission models. While both models use Microsoft Entra ID (formerly Azure AD), the ***RBAC*** model provides granular control down to individual secrets / certificates / keys in the Key Vault. When using RBAC, Owner or User Access Administrator role membership is required to assign access. Additionally, using RBAC mode provides a consistent IAM permissions model for the resource and integrates with Privileged Identity Management.

***Vault Access Policy*** can be used in use cases where developers may not have necessary privileges to set RBAC roles, where granular permissions are not required, or use cases where RBAC is not supported.

When using Key Vault Access Policies, policies are provided as if they are a RBAC role. This allows migrating to RBAC policies easier if granular access is required at a later date. The module will automatically map equivalent Access Policies based on the RBAC role named in initial permissions.

***Supported roles*** (or Access Policy equivalents) that can be passed in initial_access_assignments variable are Key Vault Administrator, Key Vault Certificates Officer, Key Vault Crypto Officer, Key Vault Crypto Service Encryption User, Key Vault Crypto User, Key Vault Reader, Key Vault Secrets Officer, and Key Vault Secrets User.

This module creates the following resources:

- Key Vault
- Diagnostic settings (At least one diagnostic setting is required with Log category enabled)
- Keys
- Private endpoint (Required when Public Access is disabled otherwise optional)

## Dependencies

- AzureRM provider version must be at least 3.87
- A resource group must exist
- VNet with subnets and private DNS zone (if needed) must exist

## Provider Block Requirements

The calling module's provider block should include the following feature. This will allow the Key Vault to be successfully destroyed using Terraform Destroy.

    provider "azurerm" {
      features {
        key_vault {
          purge_soft_delete_on_destroy = false
        }
      }
    }

## Required Inputs

| Name                                                                                                                           | Description                                                                                              | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| ------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `<a name="input_keyvault_diagnostics_settings"></a>` [keyvault\_diagnostics\_settings](#input\_keyvault\_diagnostics\_settings) | List of diagnostic settings                                                                              | `<pre>`list(object({`<br>`        name                                 = string,`<br>`        log_analytics_workspace_id           = optional(string, null),`<br>`        storage_id                           = optional(string, null),`<br>`        eventhub_authorization_rule_id       = optional(string, null),`<br>`        eventhub_name                        = optional(string, null)`<br>`        include_diagnostic_log_categories    = bool,`<br>`        include_diagnostic_metric_categories = bool  `<br>`    }))`</pre>` |
| `<a name="input_location"></a>` [location](#input\_location)                                                                    | Location to deploy Key Vault in.                                                                         | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `<a name="input_name"></a>` [name](#input\_name)                                                                                | Name of the Key Vault. Used as a prefix for other resources.                                             | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `<a name="input_required_tags"></a>` [required\_tags](#input\_required\_tags)                                                   | Required tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+v2.0) | `<pre>`object({`<br>`    AssetOwner       = string `<br>`    CostCenter       = string `<br>`    ServiceNowAS     = string `<br>`    ServiceNowBA     = string `<br>`    SecurityReviewID = string `<br>`  })`</pre>`                                                                                                                                                                                                                                                                                                                         |
| `<a name="input_resource_group_name"></a>` [resource\_group\_name](#input\_resource\_group\_name)                               | Resource group for this deployment                                                                       | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |

## Optional Inputs

| Name                                                                                                                                   | Description                                                                                                                                                                       | Type                                                                                                                                                                                                                                                 | Default   |
| -------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| `<a name="input_afdiags"></a>` [afdiags](#input\_afdiags)                                                                               | Set to true if diagnostics should be sent to SEIM                                                                                                                                 | `bool`                                                                                                                                                                                                                                             | `false` |
| `<a name="input_allowed_ip_rules"></a>` [allowed\_ip\_rules](#input\_allowed\_ip\_rules)                                                | IP Addresses allowed to access the Key Vault. This can be useful for Key Vaults used to encrypt terraform state where terraform is run from on premise.                           | `list(string)`                                                                                                                                                                                                                                     | `[]`    |
| `<a name="input_bypass_trusted_services"></a>` [bypass\_trusted\_services](#input\_bypass\_trusted\_services)                           | Allow Azure trusted services to bypass the firewall.                                                                                                                              | `bool`                                                                                                                                                                                                                                             | `false` |
| `<a name="input_enable_purge_protection"></a>` [enable\_purge\_protection](#input\_enable\_purge\_protection)                           | Boolean flag to enable purge protection.                                                                                                                                          | `bool`                                                                                                                                                                                                                                             | `true`  |
| `<a name="input_enable_rbac_authorization"></a>` [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization)                     | Use RBAC authentication for Key Vault -- this is the preferred method.                                                                                                            | `bool`                                                                                                                                                                                                                                             | `true`  |
| `<a name="input_enabled_for_deployment"></a>` [enabled\_for\_deployment](#input\_enabled\_for\_deployment)                              | Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the Key Vault.                                               | `bool`                                                                                                                                                                                                                                             | `false` |
| `<a name="input_enabled_for_disk_encryption"></a>` [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption)             | Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.                                                            | `bool`                                                                                                                                                                                                                                             | `false` |
| `<a name="input_enabled_for_template_deployment"></a>` [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment) | Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the Key Vault.                                                                       | `bool`                                                                                                                                                                                                                                             | `false` |
| `<a name="input_include_ado_cidrs"></a>` [include\_ado\_cidrs](#input\_include\_ado\_cidrs)                                             | Include ADO CIDRs to allow linking Key Vault to ADO variable group. This is useful for eviCore developers who use ADO pipelines.                                                  | `bool`                                                                                                                                                                                                                                             | `false` |
| `<a name="input_initial_access_assignments"></a>` [initial\_access\_assignments](#input\_initial\_access\_assignments)                  | Permissions to apply when Key Vault is created. If enable_rbac_authorization is set to false, RBAC roles will be automatically converted to equivalent Access Policy permissions. | `<pre>`set(object({`<br>`    principal_id   = string `<br>`    roles          = list(string)`<br>`    principal_type = string `<br>`  }))`</pre>`                                                                                        | `[]`    |
| `<a name="input_keyvault_keys"></a>` [keyvault\_keys](#input\_keyvault\_keys)                                                           | List of keys to create.                                                                                                                                                           | `<pre>`map(object({`<br>`                      key_type = optional(string, "RSA")`<br>`                      key_size = optional(number, 4096) `<br>`                      key_opts = list(string)`<br>`                     }))`</pre>` | `{}`    |
| `<a name="input_optional_tags"></a>` [optional\_tags](#input\_optional\_tags)                                                           | Optional tags to include with required tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0).                                           | `map(string)`                                                                                                                                                                                                                                      | `{}`    |
| `<a name="input_private_dns_zone_id"></a>` [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id)                                     | ID of private DNS zone for private endpoint, if private DNS zone used.                                                                                                            | `string`                                                                                                                                                                                                                                           | `""`    |
| `<a name="input_private_endpoint_subnet_id"></a>` [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id)                | ID of subnet in which to create private endpoint.                                                                                                                                 | `string`                                                                                                                                                                                                                                           | `""`    |
| `<a name="input_soft_delete_retention"></a>` [soft\_delete\_retention](#input\_soft\_delete\_retention)                                 | Number of days that the Key Vault is held in a suspended state before being wiped. May need to be set higher for use with some services such as Event Hubs.                       | `number`                                                                                                                                                                                                                                           | `7`     |
| `<a name="input_virtual_network_subnet_ids"></a>` [virtual\_network\_subnet\_ids](#input\_virtual\_network\_subnet\_ids)                | List of subnet ids allowed to connect securely and directly to Key Vault using service endpoints.                                                                                 | `list(string)`                                                                                                                                                                                                                                     | `[]`    |

## Override Inputs

These are provided for testing and rare corner-cases only. They should not be used in production unless absolutely necessary and reviewed as an exception pattern.

| Name                                                                                                   | Description                                                                                                                                                                            | Type       | Default        |
| ------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| `<a name="input_public_network_access"></a>` [public\_network\_access](#input\_public\_network\_access) | Override use only - Allow public network access (Public IP) to this Key Vault.                                                                                                         | `bool`   | `false`      |
| `<a name="input_sku_name"></a>` [sku\_name](#input\_sku\_name)                                          | Provided as an over-ride feature, in case Key Vaults that require HSM protection are required.                                                                                         | `string` | `"standard"` |
| `<a name="input_tenant_id"></a>` [tenant\_id](#input\_tenant\_id)                                       | ID of tenant Key Vault will use to authenticate requests -- provided as an over-ride in case deployment environment does not properly support client\_config data source.              | `string` | `null`       |
| `<a name="input_TimerDelay"></a>` [TimerDelay](#input\_TimerDelay)                                      | Timer delay to wait for permission assignments and/or private endpoint DNS entry and approval prior to creating a key vault key. Provided as an over-ride in case more time is needed. | `string` | `"2m"`       |

## Outputs

| Name                                   | Description                                   |
| -------------------------------------- | --------------------------------------------- |
| key\_vault\_id                         | Id of the resultant key vault                 |
| key\_vault\_URI                        | URI of the resultant key vault                |
| key\_vault\_rbac_authorization_enabled | RBAC authorization of the resultant key vault |

## Examples

See example in the repository /example folder. Additional examples are available in /test_cases.

## New in Version 3.0

- When using Key Vault Access Policies, these policies are provided as if they are a RBAC role, making migration to an RBAC mode easier. The module will map equivalent Access Policies based on the RBAC role named in initial permissions.
- Identity of deployer will no longer be given automatic permissions to Key Vault.
- Initial Permissions can be provided as a list of identities with associated permissions. The special value "self" can be used to reference deployer ID.
  - Note: some environments will not support the self value, in which case identity ID must be passed in.
- Key Vault module will no longer create a disk encryption set.

## New in Version 5.0

- Role as Self Service support when using RBAC role assignments
- Ability to create multiple Key Vault Keys

## New in Version 5.0.1

When creating a key vault with new Keys a delay is required when creating role assignments and\or creating private endpoint with public network access disabled. The delay is to accommodate time for both the role assignments and private endpoint to be created and established prior to creating the Key(s).

An optional TimerDelay variable is also available to over-ride the default timerdelay value of 2m in the event more time is required.

Additional validation check added for max allowed tags. Per MS documentation key vault resources such as secrets & keys have a max limit of 15 tags.

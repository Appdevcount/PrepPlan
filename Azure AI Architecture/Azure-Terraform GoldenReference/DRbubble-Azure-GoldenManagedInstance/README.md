# Azure-GoldenManagedInstance
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>4.0 |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_key.tde_cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_mssql_managed_database.managed_database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_managed_database) | resource |
| [azurerm_mssql_managed_instance.managed_instance](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_managed_instance) | resource |
| [azurerm_mssql_managed_instance_transparent_data_encryption.tde-setting](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_managed_instance_transparent_data_encryption) | resource |
| [azurerm_network_security_group.network_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_route_table.route_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet_network_security_group_association.subnet_network_security_group_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.subnet_route_table_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [time_sleep.wait_10_minutes](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azurerm_key_vault.tde-kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_user_assigned_identity.sqlmi_managed_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_collation"></a> [collation](#input\_collation) | SQL Server collation | `string` | `"SQL_Latin1_General_CP1_CI_AS"` | no |
| <a name="input_dns_zone_partner_id"></a> [dns\_zone\_partner\_id](#input\_dns\_zone\_partner\_id) | (Optional) The ID of the SQL Managed Instance which will share the DNS zone. This is a prerequisite for creating an `azurerm_sql_managed_instance_failover_group`. Setting this after creation forces a new resource to be created. | `string` | `null` | no |
| <a name="input_entra_admin_object_id"></a> [entra\_admin\_object\_id](#input\_entra\_admin\_object\_id) | Object ID of the Managed Identity or group to be the Entra administrator for this instance | `string` | n/a | yes |
| <a name="input_entra_admin_principal_type"></a> [entra\_admin\_principal\_type](#input\_entra\_admin\_principal\_type) | User or Group for the Entra ID admin type | `string` | n/a | yes |
| <a name="input_entra_admin_username"></a> [entra\_admin\_username](#input\_entra\_admin\_username) | Managed Identity or group to be the Entra administrator for this instance | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment. | `string` | `"dev"` | no |
| <a name="input_immutable_backups_enabled"></a> [immutable\_backups\_enabled](#input\_immutable\_backups\_enabled) | enable/diable immutable backups | `bool` | `false` | no |
| <a name="input_instance_subnet_name"></a> [instance\_subnet\_name](#input\_instance\_subnet\_name) | name of the subnet on which to create the managed instance. Should be part of the vi specified in virtual\_network\_name. | `string` | n/a | yes |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | Enter license type | `string` | `"BasePrice"` | no |
| <a name="input_location"></a> [location](#input\_location) | Enter the location where you want to deploy the resources | `string` | `"eastus"` | no |
| <a name="input_maintenance_configuration_name"></a> [maintenance\_configuration\_name](#input\_maintenance\_configuration\_name) | (Optional) The name of the Public Maintenance Configuration window to apply to the SQL Managed Instance. Valid values include `SQL_Default` or an Azure Location in the format `SQL_{Location}_MI_{Size}`(for example `SQL_EastUS_MI_1`). Defaults to `SQL_Default`. | `string` | `null` | no |
| <a name="input_managed_identity"></a> [managed\_identity](#input\_managed\_identity) | Managed Identity for this instance | `string` | n/a | yes |
| <a name="input_managed_instance_name"></a> [managed\_instance\_name](#input\_managed\_instance\_name) | name to append to the prefix that names this managed instance. will be included in networking object names | `string` | n/a | yes |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | (Optional) The Minimum TLS Version. Default value is `1.2` Valid values include `1.0`, `1.1`, `1.2`. | `string` | `"1.2"` | no |
| <a name="input_monthly_retention"></a> [monthly\_retention](#input\_monthly\_retention) | Monthly Backup retention for managed instance databases | `string` | `"PT0S"` | no |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional user tags | `map(string)` | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix of the resource name | `string` | n/a | yes |
| <a name="input_proxy_override"></a> [proxy\_override](#input\_proxy\_override) | (Optional) Specifies how the SQL Managed Instance will be accessed. Default value is `Default`. Valid values include `Default`, `Proxy`, and `Redirect`. | `string` | `null` | no |
| <a name="input_public_data_endpoint_enabled"></a> [public\_data\_endpoint\_enabled](#input\_public\_data\_endpoint\_enabled) | (Optional) Is the public data endpoint enabled? Default value is `false`. | `bool` | `null` | no |
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | Required tags | <pre>object({<br/>    AssetOwner             = string<br/>    CostCenter             = string<br/>    DataClassification     = string<br/>    ServiceNowAS           = string<br/>    SecurityReviewID       = string<br/>    ServiceNowBA           = string<br/>    LineOfBusiness         = string<br/>    BusinessEntity         = string<br/>    DataSubjectArea        = string<br/>    ComplianceDataCategory = string<br/>    P2P                    = string<br/>  })</pre> | n/a | yes |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | location of the resource group | `string` | `"East US"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | name of the resource group to use for this deployment | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Enter SKU | `string` | `"GP_Gen5"` | no |
| <a name="input_storage_account_type"></a> [storage\_account\_type](#input\_storage\_account\_type) | (Optional) Specifies the storage account type used to store backups for this database. Changing this forces a new resource to be created. Possible values are `GRS`, `LRS` and `ZRS`. Defaults to `GRS`. | `string` | `"GZRS"` | no |
| <a name="input_storage_size_in_gb"></a> [storage\_size\_in\_gb](#input\_storage\_size\_in\_gb) | Enter storage size in GB | `number` | `32` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | subscription id for all resources in this module | `string` | n/a | yes |
| <a name="input_tde_cmk_key_vault_name"></a> [tde\_cmk\_key\_vault\_name](#input\_tde\_cmk\_key\_vault\_name) | Name of the key vault to store the tde cmks | `string` | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | - `create` - (Defaults to 24 hours) Used when creating the Microsoft SQL Managed Instance.<br/>- `delete` - (Defaults to 24 hours) Used when deleting the Microsoft SQL Managed Instance.<br/>- `read` - (Defaults to 5 minutes) Used when retrieving the Microsoft SQL Managed Instance.<br/>- `update` - (Defaults to 24 hours) Used when updating the Microsoft SQL Managed Instance. | <pre>object({<br/>    create = optional(string)<br/>    delete = optional(string)<br/>    read   = optional(string)<br/>    update = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_timezone_id"></a> [timezone\_id](#input\_timezone\_id) | (Optional) The TimeZone ID that the SQL Managed Instance will be operating in. Default value is `UTC`. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_vcores"></a> [vcores](#input\_vcores) | Enter number of vCores you want to deploy | `number` | `8` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | name of the previously created virtual network | `string` | n/a | yes |
| <a name="input_week_of_year"></a> [week\_of\_year](#input\_week\_of\_year) | The week of year to take the yearly backup. Value has to be between 1 and 52. | `string` | `1` | no |
| <a name="input_weekly_retention"></a> [weekly\_retention](#input\_weekly\_retention) | Weekly Backup retention for managed instance databases | `string` | `"PT0S"` | no |
| <a name="input_yearly_retention"></a> [yearly\_retention](#input\_yearly\_retention) | Yearly Backup retention for managed instance databases | `string` | `"PT0S"` | no |
| <a name="input_zone_redundant_enabled"></a> [zone\_redundant\_enabled](#input\_zone\_redundant\_enabled) | (Optional) If true, the SQL Managed Instance will be deployed with zone redundancy.  Defaults to `true`. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_managed_instance_name"></a> [managed\_instance\_name](#output\_managed\_instance\_name) | n/a |
<!-- END_TF_DOCS -->
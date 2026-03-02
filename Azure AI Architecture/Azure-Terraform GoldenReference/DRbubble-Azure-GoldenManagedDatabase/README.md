<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_mssql_managed_database.managed_database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_managed_database) | resource |
| [azurerm_mssql_managed_instance.managed_instance](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/mssql_managed_instance) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_immutable_backups_enabled"></a> [immutable\_backups\_enabled](#input\_immutable\_backups\_enabled) | immutable backups enabled | `bool` | `false` | no |
| <a name="input_monthly_retention"></a> [monthly\_retention](#input\_monthly\_retention) | The monthly retention policy for an LTR backup in an ISO 8601 format. Valid value is between 1 to 120 months. | `string` | `"PT0S"` | no |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional user tags | `map(string)` | `{}` | no |
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | Required tags | <pre>object({<br/>    AssetOwner             = string<br/>    CostCenter             = string<br/>    DataClassification     = string<br/>    ServiceNowAS           = string<br/>    SecurityReviewID       = string<br/>    ServiceNowBA           = string<br/>    LineOfBusiness         = string<br/>    BusinessEntity         = string<br/>    DataSubjectArea        = string<br/>    ComplianceDataCategory = string<br/>    P2P                    = string<br/>  })</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | group name for all resources. | `string` | n/a | yes |
| <a name="input_short_term_retention_days"></a> [short\_term\_retention\_days](#input\_short\_term\_retention\_days) | The backup retention period in days. This is how many days Point-in-Time Restore will be supported. | `number` | `30` | no |
| <a name="input_sql_managed_database_name"></a> [sql\_managed\_database\_name](#input\_sql\_managed\_database\_name) | The name of the SQL Managed Database. | `string` | n/a | yes |
| <a name="input_sql_managed_instance_name"></a> [sql\_managed\_instance\_name](#input\_sql\_managed\_instance\_name) | The name of the SQL Managed Instance. | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | subscription id for all resources in this module | `string` | n/a | yes |
| <a name="input_week_of_year"></a> [week\_of\_year](#input\_week\_of\_year) | The week of year to take the yearly backup. Value has to be between 1 and 52 | `string` | `1` | no |
| <a name="input_weekly_retention"></a> [weekly\_retention](#input\_weekly\_retention) | The weekly retention policy for an LTR backup in an ISO 8601 format. Valid value is between 1 to 520 weeks. | `string` | `"PT0S"` | no |
| <a name="input_yearly_retention"></a> [yearly\_retention](#input\_yearly\_retention) | The yearly retention policy for an LTR backup in an ISO 8601 format. Valid value is between 1 to 10 years | `string` | `"PT0S"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | n/a |
<!-- END_TF_DOCS -->
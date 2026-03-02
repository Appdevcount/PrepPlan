>Refer to https://confluence.sys.cigna.com/display/CLOUD/Terraform+Module+Standards for Terraform module development standards and guidelines.

# Azure-GoldenAppService

## Overview

This Terraform module will deploy a Cigna standard Azure App Service (Web App) with a private endpoint and staging slot. It creates the following resources:

  - App Services Plan
  - App Service (Web App)
  - App Service deployment slot (staging)
  - Private DNS zone*
  - Private endpoint*

  *Private Endpoints are only supported for Premium tier SKUs.

## Dependencies

- Microsoft.web Resource Provider must be registered in the subscription
- Terraform version 0.13 or newer is required for this module
- A resource group must exist
- A vNet must exist with a subnet to hold the private endpoint (use Azure-GoldenVNET)
- If an App Service Environment will be used, it must exist to deploy the App Service into (use Azure-GoldenAppServiceEnv)

## Post Deployment

- Configure auto-scaling using azurerm_monitor_autoscale_setting
- If a custom domain will be added to the site, use azurerm_app_service_custom_hostname_binding and azurerm_app_service_managed_certificate to add custom domain with SSL certificate
- Deploy website code into App Service (this can be done in the Jenkins pipeline using the command <a name="az webapp deploy"> to deploy a ZIP package)

## Inputs

### REQUIRED:

| Name | Description | Type |
|------|-------------|------|
| <a name="input_name"></a> [name](#input\_name) | Name of web application to create | `string` |
| <a name="input_pe_subnet_name"></a> [pe\_subnet\_name](#input\_pe\_subnet\_name) | Name of subnet private endpoint should be deployed into | `string` |
| <a name="input_pe_virtual_network_name"></a> [pe\_virtual\_network\_name](#input\_pe\_virtual\_network\_name) | Name of vNet where private endpoint should be deployed | `string` |
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | Required Cigna tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0) | <pre>object({<br>    AssetOwner     = string<br>    CostCenter = string<br>    ServiceNowBA       = string<br>    ServiceNowAS       = string<br>    SecurityReviewID = string<br>  })</pre> |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group to deploy into | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | SKU tier and size (S1, S2, S3, P1V2, P2V2, P3V2, P1V3, P2V3, or P3V3) where S SKUs are Standard and P are Premium | `string` |

### OPTIONAL:

| Name | Description | Type | Default |
|------|-------------|------|---------|
| <a name="input_app_service_environment_id"></a> [app\_service\_environment\_id](#input\_app\_service\_environment\_id) | ID of App Service Environment to run this app in - if set plan tier must be premium | `string` | `null` |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | KEY = VALUE pairs of app settings (e.g {WEBSITE\_PRIVATE\_EXTENSIONS = 0, WEBSITE\_SLOT\_MAX\_NUMBER\_OF\_TIMEOUTS = 4}) | `map(string)` | `{}` |
| <a name="input_auth_settings"></a> [auth\_settings](#input\_auth\_settings) | If authentication is required, provide client\_id from app registration in Azure Active Directory. Allowed Audiances is optional and can be set to null if not needed. | <pre>object({<br>    enabled           = bool<br>    client_id         = string<br>    allowed_audiences = list(string)<br>  })</pre> | <pre>{<br>  "allowed_audiences": [],<br>  "client_id": "",<br>  "enabled": false<br>}</pre> |
| <a name="input_client_affinity_enabled"></a> [client\_affinity\_enabled](#input\_client\_affinity\_enabled) | Set to true if cookie based affinity should be enabled | `bool` | `false` |
| <a name="input_client_cert_enabled"></a> [client\_cert\_enabled](#input\_client\_cert\_enabled) | Set to true if this application requires mutual authentication via client certificates | `bool` | `false` |
| <a name="input_connection_strings"></a> [connection\_strings](#input\_connection\_strings) | Required app connections (name = Name of connection; type = APIHub, Custom, DocDb, EventHub, MySQL, NotificationHub, PostgreSQL, RedisCache, ServiceBus, SQLAzure or SQLServer; value = Connection String) | <pre>list(object({<br>    name  = string<br>    type  = string<br>    value = string<br>  }))</pre> | `[]` |
| <a name="input_cors_allowed_origins"></a> [cors\_allowed\_origins](#input\_cors\_allowed\_origins) | List of allowed CORS origins | `list(string)` | `[]` |
| <a name="input_ip_restriction"></a> [ip\_restriction](#input\_ip\_restriction) | Network (firewall) rules. Type should be ip\_address, service\_tag, or subnet\_id depending on the type of address provided. | <pre>list(object({<br>    type     = string<br>    name     = string<br>    priority = number<br>    action   = string<br>    address  = string<br>  }))</pre> | <pre>[<br>  {<br>    "action": "Deny",<br>    "address": "0.0.0.0/0",<br>    "name": "Deny All",<br>    "priority": 200,<br>    "type": "ip_address"<br>  }<br>]</pre> |
| <a name="input_scm_ip_restriction"></a> [scm\_ip\_restriction](#input\_scm\_ip\_restriction) | Network (firewall) rules for SCM (Kudu) access. Type should be ip\_address, service\_tag, or subnet\_id depending on the type of address provided. IP address of deployment worker machine must be included to deploy web code through zip deploy. | <pre>list(object({<br>    type     = string<br>    name     = string<br>    priority = number<br>    action   = string<br>    address  = string<br>  }))</pre> | <pre>[<br>  {<br>    "action": "Deny",<br>    "address": "0.0.0.0/0",<br>    "name": "Deny All",<br>    "priority": 200,<br>    "type": "ip_address"<br>  }<br>]</pre> |
| <a name="input_kind"></a> [kind](#input\_kind) | OS for App Service Plan (Linux or Windows) | `string` | `"Linux"` |
| <a name="input_location"></a> [location](#input\_location) | Region to deploy to | `string` | `"EastUS"` |
| <a name="input_logs"></a> [logs](#input\_logs) | Configuration of log settings | <pre>object({<br>    detailed_error_messages_enabled = bool<br>    failed_request_tracing_enabled  = bool<br>    level                           = string<br>    sas_url                         = string<br>    retention_in_days               = string<br>  })</pre> | `null` |
| <a name="input_site_config"></a> [site\_config](#input\_site\_config) | See README-site-config.md | `map(any)` | `null` |
| <a name="input_user_defined_tags"></a> [user\_defined\_tags](#input\_user\_defined\_tags) | Optional Cigna standard tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0) | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | ID of Application Service |
| <a name="output_app_identity"></a> [app\_identity](#output\_app\_identity) | Managed Identity for service application |
| <a name="output_asp_id"></a> [asp\_id](#output\_asp\_id) | ID of Application Service Plan |
| <a name="output_custom_domain_verification_id"></a> [custom\_domain\_verification\_id](#output\_custom\_domain\_verification\_id) | Identifier to perform domain ownership verification via DNS TXT record if adding custom domain |

## Usage

module "Azure-GoldenAppService" {
  source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenAppService.git?ref=2.0.0"
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_subnet.snet
  ]

  resource_group_name = "Registrations-rg"
  name                = "oeregistrations21"
  sku                 = "P1V2"
  kind = "Linux"

  required_tags = {
    AssetOwner        = "dana.williams@cigna.com"
    CostCenter        = "0009999"
    ServiceNowAS      = "0000000"
    ServiceNowBA      = "0800999"
    SecurityReviewID  = "00000000"
  }

  app_settings = {
    WEBSITE_PRIVATE_EXTENSIONS          = "0", 
    WEBSITE_SLOT_MAX_NUMBER_OF_TIMEOUTS = "4"
    WEBSITE_WARMUP_PATH                 = "/ready"
  }

  connection_strings = [{
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:oereg21-sql.database.windows.net;Initial Catalog=oereg21-db;Integrated Security=SSPI;Encrypt=True"
  }]

  site_config = {
    linux_fx_version = "NODE|14-lts"
    http2_enabled    = "true"
  }

  ip_restriction = [{
    type     = "ip_address"
    name     = "OE Team Range 1"
    priority = 5
    action   = "Allow"
    address  = "10.10.10.0/24"
    },
    {
    type     = "ip_address"
    name     = "OE Team Range 2"
    priority = 6
    action   = "Allow"
    address  = "10.10.20.0/24"
  }]

  scm_ip_restriction [{
    type     = "ip_address"
    name     = "Deployment worker"
    priority = 10
    action   = "Allow"
    address  = "100.1.1.213/32"
  }]
}

## Links

>Provide links to Cigna Service page, Cigna architectural decisions page if applicable, and examples in the "/examples" folder. Do not include any public web links.

- Service Page https://confluence.sys.cigna.com/pages/viewpage.action?pageId=424287111
- Examples https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenAppService/tree/master/examples
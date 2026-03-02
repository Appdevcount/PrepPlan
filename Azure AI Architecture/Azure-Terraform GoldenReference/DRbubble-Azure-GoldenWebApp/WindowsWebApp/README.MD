<!-- BEGIN_TF_DOCS -->
# Azure-GoldenWebApp-Windows(3.2.0)

## Overview

ALWAYS RUN A TERRAFORM PLAN TO VERIFY IF A DESTROY WILL TAKE PLACE ESPECIALLY IF YOUR PIPELINE USES AUTO APPROVE ON A TERRAFORM APPLY WITHOUT FIRST VERIFING A TERRAFORM PLAN.

This Terraform module will deploy a Cigna\eviCore standard **Windows** Web App with the following optional resources:

* App Service Plan
* App Insights and Log Analytics Workspace
* Function App Slot
* FMEA Alerts

  * Includes Alarm Funnel connectivity

Tested with the following versions:

* Terraform: v1.9.5
* Azurerm: v4.37.0
* Azuread: v2.53.1

## Dependencies

* A VNET with Subnets for vnet integration, private endpoints and a private DNS zone must exist.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.5 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.106 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.106 |

## Required Inputs
| Name | Description | Type |
|------|-------------|------|
| environment | Environment to deploy to.|<pre>string</pre> |
| location | Required: The Azure Region where the Linux Web App should exist. Changing this forces a new Linux Web App to be created.|<pre>string</pre> |
| name | Required: Base name of application to create (-plan, -app, etc will be postpended to this name for specifc resource types)|<pre>string</pre> |
| required_tags | Required: Cigna tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)|<pre>object({  <br/>    AssetOwner       = string  <br/>    CostCenter       = string  <br/>    ServiceNowBA     = string  <br/>    ServiceNowAS     = string  <br/>    SecurityReviewID = string<br/>  })</pre> |
| resource_group_name | Required: Resource group to deploy into|<pre>string</pre> |
| webapp_diagnostics_settings | List of diagnostic settings at File level.|<pre>list(object({  <br/>    name                                 = string,  <br/>    log\_analytics\_workspace\_id           = optional(string, null),  <br/>    storage\_account\_id                   = optional(string, null),  <br/>    eventhub\_authorization\_rule\_id       = optional(string, null),  <br/>    eventhub\_name                        = optional(string, null),  <br/>    include\_diagnostic\_metric\_categories = optional(bool, true)<br/>  }))</pre> |

## Optional Inputs
| Name | Description | Type | Default |
|------|-------------|------|---------|
| alarm_funnel_app_name | App Name used when registering in the alarm funnel yaml file. The variable var.name will be used if this variable is not set.|<pre>string</pre> |<pre>null</pre> |
| alarm_funnel_environment | Environment Alarm Funnel will be triggered|<pre>string</pre> |<pre>""</pre> |
| alert_email_addresses | List of email addresses to use for alert notifications.|<pre>list(string)</pre> |<pre>[]</pre> |
| alerts | Alert configuration|<pre>object({  <br/><br/>    webapp\_stopped = optional(object({  <br/>      include               = optional(bool, true)  <br/>      alarm\_funnel\_severity = optional(string, "WARN")<br/>      }), { include         = true  <br/>      alarm\_funnel\_severity = "WARN"<br/>    })  <br/><br/>    http\_server\_errors = optional(object({  <br/>      include                  = optional(bool, true)  <br/>      use\_dynamic\_criteria     = optional(bool, false)  <br/>      alarm\_funnel\_severity    = optional(string, "CRITICAL")  <br/>      alert\_severity           = optional(number, 0)  <br/>      aggregation              = optional(string, "Total")  <br/>      operator                 = optional(string, "GreaterThan")  <br/>      threshold                = optional(number, 4)  <br/>      frequency                = optional(string, "PT1M")  <br/>      window\_size              = optional(string, "PT5M")  <br/>      auto\_mitigate            = optional(bool, true)  <br/>      alert\_sensitivity        = optional(string, "Medium")  <br/>      evaluation\_total\_count   = optional(number, 4)  <br/>      evaluation\_failure\_count = optional(number, 4)<br/>      }), {  <br/>      include                  = true  <br/>      use\_dynamic\_criteria     = false  <br/>      alarm\_funnel\_severity    = "CRITICAL"  <br/>      alert\_severity           = 0  <br/>      aggregation              = "Total"  <br/>      operator                 = "GreaterThan"  <br/>      threshold                = 4  <br/>      frequency                = "PT1M"  <br/>      window\_size              = "PT5M"  <br/>      auto\_mitigate            = true  <br/>      alert\_sensitivity        = "Medium"  <br/>      evaluation\_total\_count   = 4  <br/>      evaluation\_failure\_count = 4<br/>    })  <br/><br/>    health\_check = optional(object({  <br/>      include                   = optional(bool, true)  <br/>      use\_dynamic\_criteria      = optional(bool, false)  <br/>      alarm\_funnel\_severity     = optional(string, "WARN")  <br/>      alert\_severity            = optional(number, 2)  <br/>      aggregation               = optional(string, "Average")  <br/>      operator                  = optional(string, "LessThan")  <br/>      threshold                 = optional(number, 100)  <br/>      frequency                 = optional(string, "PT1M")  <br/>      window\_size               = optional(string, "PT5M")  <br/>      auto\_mitigate             = optional(bool, true)  <br/>      alert\_sensitivity         = optional(string, "Medium")  <br/>      evaluation\_total\_count    = optional(number, 4)  <br/>      evaluation\_failure\_count  = optional(number, 4)  <br/>      include\_default\_dimension = optional(bool, false)<br/>      }), {  <br/>      include                   = true  <br/>      use\_dynamic\_criteria      = false  <br/>      alarm\_funnel\_severity     = "WARN"  <br/>      alert\_severity            = 2  <br/>      aggregation               = "Average"  <br/>      operator                  = "LessThan"  <br/>      threshold                 = 100  <br/>      frequency                 = "PT1M"  <br/>      window\_size               = "PT5M"  <br/>      auto\_mitigate             = true  <br/>      alert\_sensitivity         = "Medium"  <br/>      evaluation\_total\_count    = 4  <br/>      evaluation\_failure\_count  = 4  <br/>      include\_default\_dimension = false<br/>    })  <br/><br/>    cpu\_percentage = optional(object({  <br/>      include                   = optional(bool, true)  <br/>      use\_dynamic\_criteria      = optional(bool, false)  <br/>      alarm\_funnel\_severity     = optional(string, "WARN")  <br/>      alert\_severity            = optional(number, 2)  <br/>      aggregation               = optional(string, "Average")  <br/>      operator                  = optional(string, "GreaterThan")  <br/>      threshold                 = optional(number, 80)  <br/>      frequency                 = optional(string, "PT1M")  <br/>      window\_size               = optional(string, "PT5M")  <br/>      auto\_mitigate             = optional(bool, true)  <br/>      alert\_sensitivity         = optional(string, "Medium")  <br/>      evaluation\_total\_count    = optional(number, 4)  <br/>      evaluation\_failure\_count  = optional(number, 4)  <br/>      include\_default\_dimension = optional(bool, false)<br/>      }), {  <br/>      include                   = true  <br/>      use\_dynamic\_criteria      = false  <br/>      alarm\_funnel\_severity     = "WARN"  <br/>      alert\_severity            = 2  <br/>      aggregation               = "Average"  <br/>      operator                  = "GreaterThan"  <br/>      threshold                 = 80  <br/>      frequency                 = "PT1M"  <br/>      window\_size               = "PT5M"  <br/>      auto\_mitigate             = true  <br/>      alert\_sensitivity         = "Medium"  <br/>      evaluation\_total\_count    = 4  <br/>      evaluation\_failure\_count  = 4  <br/>      include\_default\_dimension = false<br/>    })  <br/><br/>    memory\_percentage = optional(object({  <br/>      include                   = optional(bool, true)  <br/>      use\_dynamic\_criteria      = optional(bool, false)  <br/>      alarm\_funnel\_severity     = optional(string, "WARN")  <br/>      alert\_severity            = optional(number, 2)  <br/>      aggregation               = optional(string, "Average")  <br/>      operator                  = optional(string, "GreaterThan")  <br/>      threshold                 = optional(number, 90)  <br/>      frequency                 = optional(string, "PT1M")  <br/>      window\_size               = optional(string, "PT5M")  <br/>      auto\_mitigate             = optional(bool, true)  <br/>      alert\_sensitivity         = optional(string, "Medium")  <br/>      evaluation\_total\_count    = optional(number, 4)  <br/>      evaluation\_failure\_count  = optional(number, 4)  <br/>      include\_default\_dimension = optional(bool, false)<br/>      }), {  <br/>      include                   = true  <br/>      use\_dynamic\_criteria      = false  <br/>      alarm\_funnel\_severity     = "WARN"  <br/>      alert\_severity            = 2  <br/>      aggregation               = "Average"  <br/>      operator                  = "GreaterThan"  <br/>      threshold                 = 90  <br/>      frequency                 = "PT1M"  <br/>      window\_size               = "PT5M"  <br/>      auto\_mitigate             = true  <br/>      alert\_sensitivity         = "Medium"  <br/>      evaluation\_total\_count    = 4  <br/>      evaluation\_failure\_count  = 4  <br/>      include\_default\_dimension = false<br/>    })  <br/><br/>    http\_queue\_length = optional(object({  <br/>      include                   = optional(bool, true)  <br/>      use\_dynamic\_criteria      = optional(bool, false)  <br/>      alarm\_funnel\_severity     = optional(string, "WARN")  <br/>      alert\_severity            = optional(number, 2)  <br/>      aggregation               = optional(string, "Average")  <br/>      operator                  = optional(string, "GreaterThan")  <br/>      threshold                 = optional(number, 85)  <br/>      frequency                 = optional(string, "PT1M")  <br/>      window\_size               = optional(string, "PT5M")  <br/>      auto\_mitigate             = optional(bool, true)  <br/>      alert\_sensitivity         = optional(string, "Medium")  <br/>      evaluation\_total\_count    = optional(number, 4)  <br/>      evaluation\_failure\_count  = optional(number, 4)  <br/>      include\_default\_dimension = optional(bool, false)<br/>      }), {  <br/>      include                   = true  <br/>      use\_dynamic\_criteria      = false  <br/>      alarm\_funnel\_severity     = "WARN"  <br/>      alert\_severity            = 2  <br/>      aggregation               = "Average"  <br/>      operator                  = "GreaterThan"  <br/>      threshold                 = 85  <br/>      frequency                 = "PT1M"  <br/>      window\_size               = "PT5M"  <br/>      auto\_mitigate             = true  <br/>      alert\_sensitivity         = "Medium"  <br/>      evaluation\_total\_count    = 4  <br/>      evaluation\_failure\_count  = 4  <br/>      include\_default\_dimension = false<br/>    })<br/><br/>  })</pre> |<pre>{<br/>  "cpu\_percentage": {<br/>    "aggregation": "Average",<br/>    "alarm\_funnel\_severity": "WARN",<br/>    "alert\_severity": 2,<br/>    "auto\_mitigate": true,<br/>    "frequency": "PT1M",<br/>    "include": true,<br/>    "operator": "GreaterThan",<br/>    "threshold": 80,<br/>    "use\_dynamic\_criteria": false,<br/>    "window\_size": "PT5M"<br/>  },<br/>  "health\_check": {<br/>    "aggregation": "Average",<br/>    "alarm\_funnel\_severity": "WARN",<br/>    "alert\_severity": 2,<br/>    "auto\_mitigate": true,<br/>    "frequency": "PT1M",<br/>    "include": true,<br/>    "operator": "LessThan",<br/>    "threshold": 100,<br/>    "use\_dynamic\_criteria": false,<br/>    "window\_size": "PT5M"<br/>  },<br/>  "http\_queue\_length": {<br/>    "aggregation": "Average",<br/>    "alarm\_funnel\_severity": "WARN",<br/>    "alert\_severity": 2,<br/>    "auto\_mitigate": true,<br/>    "frequency": "PT1M",<br/>    "include": true,<br/>    "operator": "GreaterThan",<br/>    "threshold": 85,<br/>    "use\_dynamic\_criteria": false,<br/>    "window\_size": "PT5M"<br/>  },<br/>  "http\_server\_errors": {<br/>    "aggregation": "Total",<br/>    "alarm\_funnel\_severity": "CRITICAL",<br/>    "alert\_sensitivity": "Medium",<br/>    "alert\_severity": 0,<br/>    "auto\_mitigate": true,<br/>    "evaluation\_failure\_count": 4,<br/>    "evaluation\_total\_count": 4,<br/>    "frequency": "PT1M",<br/>    "include": true,<br/>    "operator": "GreaterThan",<br/>    "use\_dynamic\_criteria": false,<br/>    "window\_size": "PT5M"<br/>  },<br/>  "memory\_percentage": {<br/>    "aggregation": "Average",<br/>    "alarm\_funnel\_severity": "WARN",<br/>    "alert\_severity": 2,<br/>    "auto\_mitigate": true,<br/>    "frequency": "PT1M",<br/>    "include": true,<br/>    "operator": "GreaterThan",<br/>    "threshold": 90,<br/>    "use\_dynamic\_criteria": false,<br/>    "window\_size": "PT5M"<br/>  },<br/>  "webapp\_stopped": {<br/>    "alarm\_funnel\_severity": "WARN",<br/>    "include": true<br/>  }<br/>}</pre> |
| allowed_origins | Optional: Specifies a list of origins that should be allowed to make cross-origin calls.|<pre>list(string)</pre> |<pre>null</pre> |
| always_on | Optional:  If this Windows Web App is Always On enabled. Must be explicitly set to false when using Free, F1, D1, or Shared Service Plans.|<pre>bool</pre> |<pre>false</pre> |
| app_scale_limit | The number of workers this web app can scale out to. Only applicable to apps on the Consumption and Premium plan.|<pre>number</pre> |<pre>null</pre> |
| app_service_environment_id | The ID of the App Service Environment to create this Service Plan in.|<pre>string</pre> |<pre>null</pre> |
| app_service_plan_name | Name of App Service Plan|<pre>string</pre> |<pre>""</pre> |
| app_service_plan_sku_name | Required: SKU (B1, B2, B3, S1, S2, S3, P1V2, P2V2, P3V2, P1V3, P2V3, or P3V3) for service plan. See link for full possible values: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan|<pre>string</pre> |<pre>"B1"</pre> |
| app_settings | KEY = VALUE pairs of app settings (e.g {WEBSITE\_PRIVATE\_EXTENSIONS = 0, WEBSITE\_SLOT\_MAX\_NUMBER\_OF\_TIMEOUTS = 4})|<pre>map(string)</pre> |<pre>{}</pre> |
| app_worker_count | The number of Workers for this Windows Web App.|<pre>number</pre> |<pre>null</pre> |
| appinsights_connection_string | The Connection String for linking the Windows Web App to Application Insights.|<pre>string</pre> |<pre>""</pre> |
| application_insights_key | The Instrumentation Key for connecting the Windows Web App to Application Insights.|<pre>string</pre> |<pre>""</pre> |
| auth_settings | Details for auth settings|<pre>object({  <br/>    enabled                        = optional(bool, false)  <br/>    additional\_login\_parameters    = optional(map(string), {})  <br/>    allowed\_external\_redirect\_urls = optional(list(string), [])  <br/>    default\_provider               = optional(string, null)  <br/>    runtime\_version                = optional(string, null)  <br/>    token\_refresh\_extension\_hours  = optional(number, 0)  <br/>    token\_store\_enabled            = optional(bool, false)  <br/>    unauthenticated\_client\_action  = optional(string, null)  <br/>    active\_directory = optional(object({  <br/>      allowed\_audiences          = optional(list(string), [])  <br/>      client\_id                  = string  <br/>      client\_secret              = optional(string, null)  <br/>      client\_secret\_setting\_name = optional(string, null)<br/>    }))<br/><br/>  })</pre> |<pre>{<br/>  "active\_directory": {<br/>    "client\_id": ""<br/>  },<br/>  "enabled": false<br/>}</pre> |
| auth_settings_v2 | Details for auth settings|<pre>object({  <br/>    auth\_enabled                            = bool #default false  <br/>    runtime\_version                         = optional(string, null)  <br/>    config\_file\_path                        = optional(string, null)  <br/>    require\_authentication                  = bool #default false  <br/>    unauthenticated\_action                  = optional(string, null)  <br/>    default\_provider                        = optional(string, null)  <br/>    excluded\_paths                          = optional(list(string))  <br/>    require\_https                           = bool #Default true  <br/>    http\_route\_api\_prefix                   = optional(string, null)  <br/>    forward\_proxy\_convention                = optional(string, null)  <br/>    forward\_proxy\_custom\_host\_header\_name   = optional(string, null)  <br/>    forward\_proxy\_custom\_scheme\_header\_name = optional(string, null)  <br/><br/>    active\_directory\_v2 = optional(object({  <br/>      client\_id                            = string  <br/>      tenant\_auth\_endpoint                 = string  <br/>      client\_secret\_setting\_name           = optional(string, null)  <br/>      client\_secret\_certificate\_thumbprint = optional(string, null)  <br/>      jwt\_allowed\_groups                   = optional(list(string))  <br/>      jwt\_allowed\_client\_applications      = optional(list(string))  <br/>      www\_authentication\_disabled          = bool #default false  <br/>      allowed\_groups                       = optional(list(string))  <br/>      allowed\_audiences                    = optional(list(string))  <br/>      allowed\_applications                 = optional(list(string))  <br/>      allowed\_identities                   = optional(list(string))  <br/>      login\_parameters                     = optional(map(string), {})<br/>    }))  <br/><br/>    azure\_static\_web\_app\_v2 = optional(object({  <br/>      client\_id = string<br/>    }))  <br/><br/>    microsoft\_v2 = optional(object({  <br/>      client\_id                  = string  <br/>      client\_secret\_setting\_name = string  <br/>      allowed\_audiences          = optional(list(string))  <br/>      login\_scopes               = optional(list(string))<br/>    }))  <br/><br/>    login = optional(object({  <br/>      enable\_login\_settings             = optional(bool, false)  <br/>      logout\_endpoint                   = optional(string, null)  <br/>      token\_store\_enabled               = bool #default false  <br/>      token\_refresh\_extension\_time      = optional(number, 60)  <br/>      token\_store\_path                  = optional(string, null)  <br/>      token\_store\_sas\_setting\_name      = optional(string, null)  <br/>      preserve\_url\_fragments\_for\_logins = bool #default false  <br/>      allowed\_external\_redirect\_urls    = optional(list(string))  <br/>      cookie\_expiration\_convention      = optional(string, "FixedTime")  <br/>      cookie\_expiration\_time            = optional(string, "08:00:00")  <br/>      validate\_nonce                    = bool #default false  <br/>      nonce\_expiration\_time             = optional(string, "00:05:00")<br/>    }))<br/><br/>  })</pre> |<pre>{<br/>  "auth\_enabled": false,<br/>  "require\_authentication": true,<br/>  "require\_https": true<br/>}</pre> |
| client_affinity_enabled | Set to true if cookie based affinity should be enabled|<pre>bool</pre> |<pre>false</pre> |
| client_cert_enabled | Does this application require client certification?|<pre>bool</pre> |<pre>false</pre> |
| client_certificate_enabled | Should Client Certificates be enabled?|<pre>bool</pre> |<pre>false</pre> |
| client_certificate_mode | he Client Certificate mode. Possible values are Required, Optional, and OptionalInteractiveUser. This property has no effect when client\_cert\_enabled is false.|<pre>string</pre> |<pre>"Optional"</pre> |
| connection_strings | One or more connection string blocks|<pre>list(object({  <br/>    name  = string  <br/>    type  = string  <br/>    value = string<br/>  }))</pre> |<pre>[]</pre> |
| current_stack | The Application Stack for the Windows Web App. Possible values include dotnet, dotnetcore, node, python, php, and java.|<pre>string</pre> |<pre>null</pre> |
| default_documents | Specifies a list of Default Documents for the Windows Web App.|<pre>list(string)</pre> |<pre>null</pre> |
| docker | One or more docker blocks as defined below.|<pre>object({  <br/>    registry\_url                                  = optional(string, null)  <br/>    image\_name                                    = optional(string, null)  <br/>    container\_registry\_managed\_identity\_client\_id = optional(string, null)<br/>  })</pre> |<pre>{<br/>  "container\_registry\_managed\_identity\_client\_id": null,<br/>  "image\_name": null,<br/>  "registry\_url": null<br/>}</pre> |
| dotnet_version | The version of .NET to use. Possible values include v3.0, v4.0 v6.0, v7.0 and v8.0. Defaults to v8.0.|<pre>string</pre> |<pre>"v8.0"</pre> |
| dotnetcore_version | The version of .NET to use when current\_stack is set to dotnetcore. Possible values include v4.0.|<pre>string</pre> |<pre>"v4.0"</pre> |
| elastic_instance_minimum | The number of minimum instances for this Windows Web App. Only affects apps on Elastic Premium plans.|<pre>number</pre> |<pre>null</pre> |
| external_action_group_id | Action Group Id created outside of the module|<pre>string</pre> |<pre>null</pre> |
| ftp_publish_basic_authentication_enabled | Should the default FTP Basic Authentication publishing profile be enabled.|<pre>bool</pre> |<pre>false</pre> |
| health_check_eviction_time_in_min | The amount of time in minutes that a node can be unhealthy before being removed from the load balancer. Possible values are between 2 and 10. Only valid in conjunction with health\_check\_path.|<pre>number</pre> |<pre>null</pre> |
| health_check_path | The path to be checked for this Windows Web App health.|<pre>string</pre> |<pre>null</pre> |
| identity_type | Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned (to enable both).|<pre>string</pre> |<pre>"SystemAssigned"</pre> |
| include_alert_action_group | Include alert action group.|<pre>bool</pre> |<pre>false</pre> |
| include_alerts | Include built-in module alerts.|<pre>bool</pre> |<pre>true</pre> |
| include_app_insights | Module will create an Log Analytics Workspace and App Insights|<pre>bool</pre> |<pre>false</pre> |
| include_app_service_plan | Module will create a App Service Plan|<pre>bool</pre> |<pre>false</pre> |
| include_web_app_slot | Module will create web app slot|<pre>bool</pre> |<pre>false</pre> |
| ip_restriction | Network (firewall) rules. Type should be ip\_address, service\_tag, or subnet\_id depending on the type of address provided.|<pre>list(object({  <br/>    name                      = string                 #The name which should be used for this ip\_restriction.  <br/>    priority                  = number                 #The priority value of this ip\_restriction. Defaults to 65000.  <br/>    action                    = string                 #The action to take. Possible values are Allow or Deny.  <br/>    ip\_address                = optional(string, null) #The CIDR notation of the IP or IP Range to match. For example: 10.0.0.0/24 or 192.168.10.1/32  <br/>    virtual\_network\_subnet\_id = optional(string, null) #The Virtual Network Subnet ID used for this IP Restriction.  <br/>    service\_tag               = optional(string, null) #The Service Tag used for this IP Restriction.  <br/>    headers = optional(list(object({  <br/>      x\_azure\_fdid      = optional(list(string), [])  <br/>      x\_fd\_health\_probe = optional(list(string), [])  <br/>      x\_forwarded\_for   = optional(list(string), [])  <br/>      x\_forwarded\_host  = optional(list(string), [])<br/>    })), [])<br/>  }))</pre> |<pre>[]</pre> |
| java_embedded_server_enabled | Should the Java Embedded Server (Java SE) be used to run the app.|<pre>bool</pre> |<pre>"false"</pre> |
| java_version | The version of Java to use when current\_stack is set to java.|<pre>string</pre> |<pre>"17"</pre> |
| load_balancing_mode | The Site load balancing mode. Possible values include: WeightedRoundRobin, LeastRequests, LeastResponseTime, WeightedTotalTraffic, RequestHash, PerSiteRoundRobin. Defaults to LeastRequests.|<pre>string</pre> |<pre>null</pre> |
| logs | Log block for adding logs.|<pre>object({  <br/>    detailed\_error\_messages = optional(bool, false)  <br/>    failed\_request\_tracing  = optional(bool, false)  <br/>    application\_logs = optional(object({  <br/>      azure\_blob\_storage = optional(object({  <br/>        level             = string  <br/>        retention\_in\_days = number  <br/>        sas\_url           = string<br/>      }), null)  <br/>      file\_system\_level = string #Possible values include: Off, Verbose, Information, Warning, and Error.<br/>    }), null)  <br/>    http\_logs = optional(object({  <br/>      azure\_blob\_storage = optional(object({  <br/>        retention\_in\_days = number  <br/>        sas\_url           = string<br/>      }), null)  <br/>      file\_system = optional(object({  <br/>        retention\_in\_days = number  <br/>        retention\_in\_mb   = number<br/><br/>      }), null)<br/><br/>    }), null)<br/>  })</pre> |<pre>null</pre> |
| managed_pipeline_mode | Managed pipeline mode. Possible values include: Integrated, Classic.|<pre>string</pre> |<pre>"Integrated"</pre> |
| minimum_tls_version | Configures the minimum version of TLS required for SSL requests. Possible values include: 1.2 and 1.3. Defaults to 1.3.|<pre>string</pre> |<pre>"1.3"</pre> |
| node_version | The version of node to use when current\_stack is set to node. Possible values are ~12, ~14, ~16, ~18 and ~20. This property conflicts with java\_version.|<pre>string</pre> |<pre>"~20"</pre> |
| nonroutable_private_endpoint | Set to True if enabling non-routable Private Endpoints using a non-routable vnet.|<pre>bool</pre> |<pre>false</pre> |
| optional_tags | Optional: Cigna standard tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)|<pre>map(string)</pre> |<pre>{}</pre> |
| per_site_scaling_enabled | Should Per Site Scaling be enabled. Defaults to false.|<pre>bool</pre> |<pre>false</pre> |
| php_version | The version of PHP to use when current\_stack is set to php. Possible values are 7.1, 7.4 and Off. The value Off is used to signify latest supported by the service.|<pre>string</pre> |<pre>"7.4"</pre> |
| plan_maximum_elastic_worker_count | The maximum number of workers to use in an Elastic SKU Plan. Cannot be set unless using an Elastic SKU.|<pre>number</pre> |<pre>null</pre> |
| plan_worker_count | The number of Workers (instances) to be allocated at Plan level.|<pre>number</pre> |<pre>"1"</pre> |
| pre_warmed_instance_count | The number of pre-warmed instances for this Windows Web App. Only affects apps on an Elastic Premium plan.|<pre>number</pre> |<pre>null</pre> |
| private_dns_zone_id | Optional: Private DNS Zone ID.|<pre>string</pre> |<pre>""</pre> |
| private_dns_zone_name | Optional: Private DNS Zone Name. Example: privatelink.azurewebsites.net|<pre>string</pre> |<pre>""</pre> |
| private_endpoint_subnet_id | The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint.|<pre>string</pre> |<pre>""</pre> |
| public_network_access_enabled | Should public network access be enabled for the Web App.|<pre>bool</pre> |<pre>"false"</pre> |
| remote_debugging_enabled | Should Remote Debugging be enabled.|<pre>bool</pre> |<pre>false</pre> |
| runtime_scale_monitoring_enabled | Web App runtime scale monitoring can only be enabled for Elastic Premium Web Apps or Workflow Standard Logic Apps and requires a minimum prewarmed instance count of 1.|<pre>bool</pre> |<pre>false</pre> |
| scm_ip_restriction | Network (firewall) rules. Type should be ip\_address, service\_tag, or subnet\_id depending on the type of address provided.|<pre>list(object({  <br/>    name                      = string                 #The name which should be used for this ip\_restriction.  <br/>    priority                  = number                 #The priority value of this ip\_restriction. Defaults to 65000.  <br/>    action                    = string                 #The action to take. Possible values are Allow or Deny.  <br/>    ip\_address                = optional(string, null) #The CIDR notation of the IP or IP Range to match. For example: 10.0.0.0/24 or 192.168.10.1/32  <br/>    virtual\_network\_subnet\_id = optional(string, null) #The Virtual Network Subnet ID used for this IP Restriction.  <br/>    service\_tag               = optional(string, null) #The Service Tag used for this IP Restriction.  <br/>    headers = optional(list(object({  <br/>      x\_azure\_fdid      = optional(list(string), [])  <br/>      x\_fd\_health\_probe = optional(list(string), [])  <br/>      x\_forwarded\_for   = optional(list(string), [])  <br/>      x\_forwarded\_host  = optional(list(string), [])<br/>    })), [])<br/>  }))</pre> |<pre>[]</pre> |
| scm_minimum_tls_version | Configures the minimum version of TLS required for SSL requests. Possible values include: 1.2 and 1.3. Defaults to 1.3.|<pre>string</pre> |<pre>"1.3"</pre> |
| scm_use_main_ip_restriction | Should the Windows Function App ip\_restriction configuration be used for the SCM also.|<pre>bool</pre> |<pre>false</pre> |
| service_plan_id | Required: The ID of the App Service Plan within which to create this Web App.|<pre>string</pre> |<pre>""</pre> |
| sticky_settings_app_setting_names | Optional: A list of app\_setting names that the Linux Web App will not swap between Slots when a swap operation is triggered.|<pre>list(string)</pre> |<pre>null</pre> |
| sticky_settings_connection_string_names | Optional: A list of connection\_string names that the Linux Web App will not swap between Slots when a swap operation is triggered.|<pre>list(string)</pre> |<pre>null</pre> |
| storage_account | Storage account block.|<pre>object({  <br/>    access\_key   = string  <br/>    account\_name = string  <br/>    name         = string  <br/>    share\_name   = string  <br/>    type         = string  <br/>    mount\_path   = optional(string, null)<br/>  })</pre> |<pre>null</pre> |
| support_credentials | Optional: Are credentials allowed in CORS requests.|<pre>bool</pre> |<pre>false</pre> |
| timeouts | Allows you to specify timeouts for certain actions|<pre>object({  <br/>    create = optional(string, null)  <br/>    read   = optional(string, null)  <br/>    update = optional(string, null)  <br/>    delete = optional(string, null)<br/>  })</pre> |<pre>{<br/>  "create": null,<br/>  "delete": null,<br/>  "read": null,<br/>  "update": null<br/>}</pre> |
| tomcat_version | ) The version of Tomcat the Java App should use. Conflicts with java\_embedded\_server\_enabled|<pre>string</pre> |<pre>""</pre> |
| use_32_bit_worker | Is the Windows Web App using a 32-bit worker process?|<pre>bool</pre> |<pre>false</pre> |
| use_docker | Use Node programming language.|<pre>bool</pre> |<pre>false</pre> |
| use_dotnet | Use .Net programming language.|<pre>bool</pre> |<pre>false</pre> |
| use_dotnetcore | Use .Net Core programming language.|<pre>bool</pre> |<pre>false</pre> |
| use_java | Use Java programming language.|<pre>bool</pre> |<pre>false</pre> |
| use_node | Use Node programming language.|<pre>bool</pre> |<pre>false</pre> |
| use_php | Use PHP programming language.|<pre>bool</pre> |<pre>false</pre> |
| use_python | Specifies whether this is a Python app.|<pre>bool</pre> |<pre>false</pre> |
| user_assigned_identity_ids | Specifies a list of User Assigned Managed Identity IDs to be assigned to this Storage Account.|<pre>list(string)</pre> |<pre>[]</pre> |
| virtual_application | Virtual directory block.|<pre>list(object({  <br/>    physical\_path = string  <br/>    preload       = string  <br/>    virtual\_path  = string  <br/>    virtual\_directory = optional(list(object({  <br/>      physical\_path = optional(string, null)  <br/>      virtual\_path  = optional(string, null)<br/>    })), [])<br/>  }))</pre> |<pre>[]</pre> |
| virtual_network_subnet_id | Optional: The subnet id which will be used by this Web App for regional virtual network integration.|<pre>string</pre> |<pre>null</pre> |
| vnet_route_all_enabled | value|<pre>bool</pre> |<pre>false</pre> |
| web_app_slot | Details for creating Web App Slot|<pre>object({  <br/>    name                       = string  <br/>    auto\_swap\_slot\_name        = optional(string, null)  <br/>    service\_plan\_id            = optional(string, null)  <br/>    app\_settings               = optional(map(string), {})  <br/>    private\_endpoint\_subnet\_id = optional(string, "")  <br/>    private\_dns\_zone\_id        = optional(string, "") #For Cigna tenant only  <br/>    use\_docker                 = optional(bool, false)  <br/>    registry\_url               = optional(string, null)  <br/>    image\_name                 = optional(string, null)  <br/>    container\_registry\_managed\_identity\_client\_id = optional(string, null)  <br/>    ip\_restriction = optional(list(object({  <br/>      name                      = string                 #The name which should be used for this ip\_restriction.  <br/>      priority                  = number                 #The priority value of this ip\_restriction. Defaults to 65000.  <br/>      action                    = string                 #The action to take. Possible values are Allow or Deny.  <br/>      ip\_address                = optional(string, null) #The CIDR notation of the IP or IP Range to match. For example: 10.0.0.0/24 or 192.168.10.1/32  <br/>      virtual\_network\_subnet\_id = optional(string, null) #The Virtual Network Subnet ID used for this IP Restriction.  <br/>      service\_tag               = optional(string, null) #The Service Tag used for this IP Restriction.  <br/>      headers = optional(list(object({  <br/>        x\_azure\_fdid      = optional(list(string), [])  <br/>        x\_fd\_health\_probe = optional(list(string), [])  <br/>        x\_forwarded\_for   = optional(list(string), [])  <br/>        x\_forwarded\_host  = optional(list(string), [])<br/>      })), [])<br/>    })), [])  <br/>    scm\_ip\_restriction = optional(list(object({  <br/>      name                      = string                 #The name which should be used for this ip\_restriction.  <br/>      priority                  = number                 #The priority value of this ip\_restriction. Defaults to 65000.  <br/>      action                    = string                 #The action to take. Possible values are Allow or Deny.  <br/>      ip\_address                = optional(string, null) #The CIDR notation of the IP or IP Range to match. For example: 10.0.0.0/24 or 192.168.10.1/32  <br/>      virtual\_network\_subnet\_id = optional(string, null) #The Virtual Network Subnet ID used for this IP Restriction.  <br/>      service\_tag               = optional(string, null) #The Service Tag used for this IP Restriction.  <br/>      headers = optional(list(object({  <br/>        x\_azure\_fdid      = optional(list(string), [])  <br/>        x\_fd\_health\_probe = optional(list(string), [])  <br/>        x\_forwarded\_for   = optional(list(string), [])  <br/>        x\_forwarded\_host  = optional(list(string), [])<br/>      })), [])<br/>    })), [])<br/><br/><br/>  })</pre> |<pre>{<br/>  "name": ""<br/>}</pre> |
| webdeploy_publish_basic_authentication_enabled | Should the default WebDeploy Basic Authentication publishing credentials enabled.|<pre>bool</pre> |<pre>false</pre> |
| zip_deploy_file | The local path and filename of the Zip packaged application to deploy to this Windows Web App. Using this value requires either WEBSITE\_RUN\_FROM\_PACKAGE=1 or SCM\_DO\_BUILD\_DURING\_DEPLOYMENT=true to be set on the App in app\_settings.|<pre>string</pre> |<pre>null</pre> |
| zone_balancing_enabled | Should the Service Plan balance across Availability Zones in the region. Changing this forces a new resource to be created.|<pre>bool</pre> |<pre>false</pre> |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_action_group_id"></a> [action\_group\_id](#output\_action\_group\_id) | Action group Id created within the module |
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | Web App ID |
| <a name="output_app_identity"></a> [app\_identity](#output\_app\_identity) | Web App Identity ID |
| <a name="output_app_service_name"></a> [app\_service\_name](#output\_app\_service\_name) | Name of the created App Service |
| <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id) | App service plan Id created within the module |
| <a name="output_app_service_url"></a> [app\_service\_url](#output\_app\_service\_url) | Url for the created App Service |
| <a name="output_app_slot_id"></a> [app\_slot\_id](#output\_app\_slot\_id) | Web App slot ID |
| <a name="output_app_slot_identity"></a> [app\_slot\_identity](#output\_app\_slot\_identity) | Web App slot Identity ID |
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | Application Insights Id created within the module |

## New in Version 3.2.0

* New TLS default version
  * The default TLS version is set to 1.3
  * TLS version 1.2 is also supported using the following variables
    * minimum_tls_version
    * scm_minimum_tls_version

## New in Version 3.1.0

* Updated Private Endpoint DNS Zone setting
  * Private DNS Zone setting is available for both tenants and should only be used with non-routable vnets
  * New variable: nonroutable_private_endpoint. See details in variable section of this document.

## New in Version 3.0.0

* Docker deployment enhancement

  * Option to deploy a docker container to web slot (non-production) only, allowing more control over how and when a new web app change is  deployed to the Production slot. In previous versions when using docker deployment, the container was being deployed to both the Production and non-production slot.
* Ability to pass in externally created action group that can be used with the built-in alerts.

  * When deploying a terraform workload that includes several resources that use the built-in alerts, all alerts across all resources can now be associate to one action group.
* New output values added

  * app_slot_id
  * app_slot_identity
  * application_insights_id
* Modified how private endpoint name is created.

  * The name change helps prevent the max 80 character limit.
    * **NOTE: This will delete and re-create private endpoints created in previous versions.**
* New example added: Use Case - Container Deployment
* Fix default values for alert http_server_errors
* Added support for the following features:

  * webdeploy_publish_basic_authentication_enabled
  * ftp_publish_basic_authentication_enabled

## New in Version 2.2.0

* New output values added: action_group_id and app_service_plan_id
  * The module has an option to create an action group when including alerts. The new output value will provide the Id of the action group which can then be used outside of the module if additional alerts are required and created outside of the module and need to be linked to the action group created within the module.
* New example added
  * Example demonstrates how to add additional alerts outside of the module and using the action group and app service plan  created within the module. See example under Linux folder. Same example can be applied to Windows.

## New in Version 2.1.1

* Enable alarm funnel for dev environment
* New example added (How to create multiple web-apps)
* Changed default value to null for variable: health_check_eviction_time_in_min
* Added attribute: auto_swap_slot_name for slot deployments
* Golden module tags added

## New in Version 2.1.0

* Added new optional variable for alarm funnel app name
  * Alarm funnel configuration requires an app name as part of the description configuration.
    This variable can be used to override the var.name variable.

## New in Version 2.0.0

* AzureRM v4 compatible
* Added FMEA Alerts - Alarm Funnel
  * Ability to create FMEA suggested alerts
  * Ability to auto connect alarm funnel by tenant
  * Ability to create optional alert action group
    * Includes ability to add multiple email addresses
  * Ability to fine tune alert trigger criteria

The only requirement to use the default behaviour is to provide a valid Alarm Funnel environment. See reference link below for Alarm Funnel documentation.
The module will determine the correct Alarm Funnel tenant subscription and action group to use without any user input.

The module includes the following alerts:

* web_stopped alert
* http_server_errors alert
* health_check alert
* cpu_percentage alert
* memory_percentage alert
* http_queue_length alert

  Each alert trigger criteria comes with default values and are overridable.

The following arguments are available to configure:

* severity
* scopes
* frequency
* window_size
* auto_mitigate
* static criteria
  * metric_namespace
  * metric_name
  * aggregation
  * operator
  * threshold
* dynamic criteria
  * aggregation
  * operator
  * alert_sensitivity
  * evaluation_total_count
  * evaluation_failure_count
* For both static and dynamic criteria, an optional Dimension can be included for granular monitoring
  * Dimension: ActivityName
* **Refer to the Optional Inputs section of this document for default values.**

All alerts have the option to be included\excluded.

An optional alert action group is also available with the ability to assign multiple email addresses.

The module includes the following validation checks:

* A valid Alarm Funnel environment value is used
* A valid Alarm Funnel severity level value is used
* If the option to include a alert action group, validation check to ensure at least one email address is included.

Reference links:

* [Alarm Funnel](https://confluence.sys.cigna.com/display/CLOUD/Alarm+Funnel+-+Azure)
* [FMEA Alerts](https://confluence.sys.cigna.com/pages/viewpage.action?pageId=332060441)

## New in Version 1.0.0

* Initial Release

## Examples

See example in the repository /examples folder.

## Links

[Terraform Golden Module Catalog](https://confluence.sys.cigna.com/display/CLOUD/Terraform+Golden+Modules)
<!-- END_TF_DOCS -->
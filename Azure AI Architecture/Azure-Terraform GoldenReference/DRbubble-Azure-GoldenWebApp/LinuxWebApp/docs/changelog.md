## New in Version 3.2.0

* New TLS default version

  * The default TLS version is set to 1.3
  * TLS version 1.2 is also supported using the following variables
    * minimum_tls_version
    * scm_minimum_tls_version
* Support for vnet_image_pull_enabled setting for docker containers

  * Prior versions required azapi to set this value.
  * Requires AzureRM version 4.36 or higher

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
* New example added: Use Case - Docker Deployment
* Fix default values for alert http_server_errors
* Added support for the following features:

  * webdeploy_publish_basic_authentication_enabled
  * ftp_publish_basic_authentication_enabled

## New in Version 2.2.0

* New output values added: action_group_id and app_service_plan_id

  * The module has an option to create an action group when including alerts. The new output value will provide the Id of the action group which can then be used outside of the module if additional alerts are required and created outside of the module and need to be linked to the action group created within the module.
* New example added

  * Example demonstrates how to add additional alerts outside of the module and using the action group and app service plan created within the module. See example under Linux folder. Same example can be applied to Windows.

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

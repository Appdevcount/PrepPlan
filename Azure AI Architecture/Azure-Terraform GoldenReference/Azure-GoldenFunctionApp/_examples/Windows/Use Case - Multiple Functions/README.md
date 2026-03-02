# Function App - Windows OS example

> This example shows how to create multiple Windows Function Apps using shared Storage Account, App Service Plan and App Insights.
>
> The module will create the following resources and configurations:
>
> * Windows Function App
>
>   * Application Stack: .Net v8.0
>   * VNet Integration
>   * Private Endpoint
>   * Custom App Settings
>   * Sticky Settings (for use with Slots)
>   * CORs support
>   * Public Network Access Disable
>     * Can also create access restriction rules for both main and SCM sites
>   * App Scaling
>   * Health check
>   * Diagnostic settings
>   * Require Tags
>   * System Identity
> * Managed Identity Role assignments between Function App and Storage Account
> * Alerts
>
>   * Includes connection to Alarm Funnel Action Group
>   * New Action Group for email alerts outside of Alarm Funnel
>   * Several FMEA Alerts
>
> # Resource Dependencies
>
> The following resource dependencies are created outside of this module:
> Storage Account, App Service Plan, AppInsights and Log Analytics Workspace
>
> This examples demonstrates how to create the storage account using storage account golden module and passing it to
> to this module. It also shows the App Service Plan, App Insights and Log Analytics Workspace  being created outside of this module.

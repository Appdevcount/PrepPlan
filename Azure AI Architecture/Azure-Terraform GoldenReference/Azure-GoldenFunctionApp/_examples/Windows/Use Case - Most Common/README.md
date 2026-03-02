# Function App - Windows OS example

> This example shows how to create one Windows Function App.
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
> * App Service Plan
>
>   * Using Standard Plan
> * Function App Slot
>
>   * Include required role assignments between Slot and Storage Account
>   * Private endpoint & vnet integration
>   * Access restrictions (Main & SCM)
>   * App Insights
>   * Diagnostic settings
> * Managed Identity Role assignments between Function App and Storage Account
> * App Insights
>
>   * Includes Log Analytics Workspace
> * Alerts
>
>   * Includes connection to Alarm Funnel Action Group
>   * New Action Group for email alerts outside of Alarm Funnel
>   * Several FMEA Alerts
>
> # Dependencies
>
> Storage Account for the Function App.
>
> This examples demonstrates how to create the storage account using storage account golden module and passing it to
> to this module.
>
>

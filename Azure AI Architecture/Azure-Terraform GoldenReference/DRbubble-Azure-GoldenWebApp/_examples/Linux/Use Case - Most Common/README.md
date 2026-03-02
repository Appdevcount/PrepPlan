# Web App - Linux OS example

> This example shows how to create one Linux Web App.
>
> The module will create the following resources and configurations:
>
> * Linux WebApp
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
> * WebApp Slot
>
>   * Private endpoint & vnet integration
>   * Access restrictions (Main & SCM)
>   * App Insights
>   * Diagnostic settings
> * Managed Identity Role assignments between WebApp and Storage Account
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
> * Existing VNet\Subnets for VNet Integration and Private Endpoints
> * Existing Private DNS Zone
> * Existing Log Analytics Workspace for Diagnostic Settings

# Azure-GoldenEventHub Single Region Example

This example creates a Standard Tier Event Hub namespace with event hubs. A Log Analytics Workspace is created for Event Hub diagnostics.

This example assumes a resource group has already been created, and that a VNet exists for the Private Endpoint.

Shared Access Policies are created because hypothetical application for this example cannot authenticate through AD integrated RBAC
# Azure-GoldenEventHub Dedicated Cluster Example

This example creates a Dedicated Event Hub cluster, then uses the Azure-GoldenEventHub module to creat a single region Event Hub namespace with event hubs.

This example assumes a resource group has already been created, and that a VNet exists for the Private Endpoint.

Shared Access Policies are created because hypothetical application for this example cannot authenticate through AD integrated RBAC
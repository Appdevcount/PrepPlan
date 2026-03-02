locals {
  #Avoid deployment error if user tried to pass in "Basic" SKU with a dedicated cluster
  sku = var.sku == "Standard" || var.dr_dedicated_cluster_id != null ? "Standard" : var.sku
}

resource "azurerm_eventhub_namespace" "drnamespace" {
  #Basic SKU does not support DR
  count = var.dr_location != null && local.sku == "Standard" ? 1 : 0

  name                      = "${var.name}-secondary"
  dedicated_cluster_id      = var.dr_dedicated_cluster_id
  location                  = var.dr_location
  resource_group_name       = var.resource_group_name
  sku                       = "Standard"

  #This namespace will be synchronized to the primary, so any changes should be ignored
  lifecycle {
    ignore_changes = all
  }
}

resource azurerm_private_endpoint "drendpoint" {
  #Basic SKU does not support DR
  count = var.private_endpoints && var.dr_location != null && var.sku != "Basic" ? 1 : 0

  name                 = "pe-dr_${var.name}"
  location             = var.dr_location
  resource_group_name  = var.pe_dr_resource_group_name != null ? var.pe_dr_resource_group_name : var.resource_group_name
  subnet_id            = var.pe_dr_subnet_id

  private_service_connection {
    name                           = "pecn-dr_${var.name}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_eventhub_namespace.drnamespace[0].id
    subresource_names              = ["namespace"]
  }

  tags = local.tags
}

resource "azurerm_eventhub_namespace_disaster_recovery_config" "dr" {
  count = var.dr_location != null && var.sku == "Standard" ? 1 : 0
  # Private endpoints should be in place prior to pairing
  depends_on = [azurerm_private_endpoint.drendpoint, azurerm_private_endpoint.endpoint]

  name                 = "${var.name}-pair"
  resource_group_name  = var.pe_resource_group_name != null ? var.pe_resource_group_name : var.resource_group_name
  namespace_name       = azurerm_eventhub_namespace.namespace.name
  partner_namespace_id = azurerm_eventhub_namespace.drnamespace[0].id
}
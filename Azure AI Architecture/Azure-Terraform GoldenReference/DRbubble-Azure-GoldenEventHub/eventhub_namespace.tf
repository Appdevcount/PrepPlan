resource azurerm_eventhub_namespace namespace {

  name                                = var.name
  dedicated_cluster_id                = var.dedicated_cluster_id
  resource_group_name                 = var.resource_group_name
  location                            = var.location
  
  #If this is for a dedicated cluster, force following configuration items to compatible values
  sku                                 = var.dedicated_cluster_id == null ? var.sku : "Standard"
  zone_redundant                      = var.dedicated_cluster_id == null ? var.zone_redundant : null
  capacity                            = var.dedicated_cluster_id == null ? var.capacity : null
  
  #These only apply to standard tier (and MTU should only be set if enabled)
  auto_inflate_enabled                = var.sku == "Standard" ? var.auto_inflate_enabled : null
  maximum_throughput_units            = var.auto_inflate_enabled == true && var.sku == "Standard" ? var.maximum_throughput_units : null

  identity {
    type                              = "SystemAssigned"
  }

  tags                                = local.tags

  dynamic network_rulesets {
    #This is to work around a Terraform bug that will produce invalid "There is no variable named var"
    #error message if the dynamic block construct is not included here
    for_each = var.allowed_subnet_ids != null && var.allowed_ip_ranges != null ? ["1"] : ["0"]

      content {
        default_action                  = "Deny"
        trusted_service_access_enabled  = var.trusted_service_access_enabled
 
        dynamic virtual_network_rule {
          for_each = var.allowed_subnet_ids
          content {
            subnet_id                   = virtual_network_rule.value
            ignore_missing_virtual_network_service_endpoint = true
          }
        }

        dynamic ip_rule {
          for_each = var.allowed_ip_ranges
            content {
              ip_mask                     = ip_rule.value
            }
        }
      }
  }
}

resource azurerm_eventhub_namespace_authorization_rule nssap {
  for_each            = var.namespace_shared_access_policies != null ? var.namespace_shared_access_policies : {}
  name                = each.key
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  resource_group_name = var.resource_group_name
  listen              = each.value.listen
  send                = each.value.send
  manage              = false
}

resource azurerm_private_endpoint "endpoint" {
  # Basic SKU does not support private endpoint, so check if endpoint is set and if sku is basic
  count = var.private_endpoints && var.sku != "Basic" ? 1 : 0

  name                 = "pe-${var.name}"
  location             = var.location
  resource_group_name  = var.pe_resource_group_name != null ? var.pe_resource_group_name : var.resource_group_name
  subnet_id            = var.pe_subnet_id

  private_service_connection {
    name                           = "pecn-${var.name}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_eventhub_namespace.namespace.id
    subresource_names              = ["namespace"]
  }

  tags = local.tags
}
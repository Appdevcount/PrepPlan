#Create the event hubs in namespace already created
resource azurerm_eventhub eventhub {
  for_each                  = var.event_hubs

  name                      = each.key
  namespace_name            = azurerm_eventhub_namespace.namespace.name
  resource_group_name       = var.resource_group_name
  partition_count           = each.value.partition_count
  message_retention         = each.value.message_retention
}

#Add consumer groups to the event hubs
locals {
  #Only a single default consumer group is support by Basic tier -- force to empty set if Basic is passed in
  event_hubs = var.sku == "Basic" ? {} : var.event_hubs
  #Flatten hub variable to allow access to the nested consumer groups (using for_each)
  hub_consumer_groups = flatten ([
    for hub_name, hub_conf in local.event_hubs: [
      for group in hub_conf.consumer_groups: {
        hub_name            = hub_name
        consumer_group_name = group
      }
    ]
  ])
}

resource azurerm_eventhub_consumer_group consumer_group {
  depends_on = [azurerm_eventhub.eventhub]
  for_each = {for group in local.hub_consumer_groups : "${group.hub_name}.${group.consumer_group_name}" => group}

  #Referenced this way (instead of direct variable) so Terraform can infer dependency
  namespace_name            = azurerm_eventhub_namespace.namespace.name
  
  resource_group_name       = var.resource_group_name
  eventhub_name             = each.value.hub_name
  name                      = each.value.consumer_group_name
}


#Add Shared Access rules to the event hubs
locals {
	#Flatten hub variable to allow access to the nested shared access policies (using for_each).
  hub_access_policies = flatten([
		for hub_name, hub_conf in var.event_hubs: [
			for policy_name, policy_conf in hub_conf.access_policies: {
        hub_name            = hub_name
        policy_name         = policy_name
  			send                = policy_conf.send
				listen              = policy_conf.listen
				}
    ]
	])
}

resource azurerm_eventhub_authorization_rule eventhub_allowed {
  depends_on = [azurerm_eventhub.eventhub]
  for_each = {for policy in local.hub_access_policies : "${policy.hub_name}.${policy.policy_name}" => policy}

  #These are referenced this way (instead of direct variable) so Terraform can infer dependencies
  namespace_name            = azurerm_eventhub_namespace.namespace.name
  resource_group_name       = var.resource_group_name
  
  eventhub_name             = each.value.hub_name
  name                      = each.value.policy_name
  send                      = each.value.send
  listen                    = each.value.listen
  manage                    = false
}
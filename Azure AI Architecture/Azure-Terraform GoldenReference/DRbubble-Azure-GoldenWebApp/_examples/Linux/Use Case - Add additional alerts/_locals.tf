locals {

  alarm_funnel_tenant = {
    "595de295-db43-4c19-8b50-183dfd4a3d06" = {
      "action_group_id" = "/subscriptions/4291f6cb-6acb-4857-8d9a-3510df28ce1d/resourceGroups/AlarmFunnel-rg/providers/microsoft.insights/actiongroups/AlarmFunnel-ag"
    }
    "791b26cb-3fdf-47c3-b85d-bd9f037e3e7f" = {
      "action_group_id" = "/subscriptions/9f7af41c-8074-4bc0-8cea-09b846ffc3f7/resourceGroups/Alarm-Funnel-prod-rg/providers/Microsoft.Insights/actiongroups/AlarmFunnel-ag"
    }
  }

  alarm_funnel = lookup(local.alarm_funnel_tenant, data.azurerm_client_config.current.tenant_id)

}
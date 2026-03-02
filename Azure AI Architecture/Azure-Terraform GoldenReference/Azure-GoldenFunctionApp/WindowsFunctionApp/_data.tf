data "azurerm_monitor_action_group" "alarm_funnel" {
  provider            = azurerm.alarm_funnel_ag_subscription
  count               = var.include_alerts ? 1 : 0 
  resource_group_name = var.alarm_funnel_resourcegroup_name
  name                = var.alarm_funnel_action_group_name
}
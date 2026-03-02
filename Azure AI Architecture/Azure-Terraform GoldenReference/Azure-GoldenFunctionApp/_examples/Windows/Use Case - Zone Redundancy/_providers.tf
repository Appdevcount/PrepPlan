provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias = "alarm_funnel_ag_subscription"
  subscription_id = var.alarm_funnel_ag_subscription_id
  features {}
}

locals {
  environment_type   = var.production == false ? "nonprod" : "prod"
  vnet_environment   = var.environment != "" ? format("%s%s", var.environment, "-") : ""
  vnet_prefix_name   = var.location_abrv != "" ? format("%s%s%s", local.vnet_environment, var.location_abrv, "-") : local.vnet_environment

  protected_subnet_names = [
    "AzureBastionSubnet",
    "AzureFirewallSubnet",
    "GatewaySubnet"
  ]
  
  tags =  merge(
    var.required_tags,
    var.optional_tags,
  )
}
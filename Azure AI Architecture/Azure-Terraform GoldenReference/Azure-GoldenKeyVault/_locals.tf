locals {

  create_private_endpoint = (!var.public_network_access || length(var.private_endpoint_subnet_id) > 0)
  enable_private_dns_zone_group = data.azurerm_client_config.current.tenant_id == "595de295-db43-4c19-8b50-183dfd4a3d06" ? false : true
  
  allowed_ado_ip_rules = ["20.37.158.0/23","52.150.138.0/24","40.80.187.0/24","40.119.10.0/24","20.42.5.0/24","20.41.6.0/23","40.80.187.0/24","40.119.10.0/24","40.82.252.0/24","20.42.134.0/23","20.125.155.0/24"]
  allowed_ips = var.include_ado_cidrs ? concat(var.allowed_ip_rules, local.allowed_ado_ip_rules) : var.allowed_ip_rules
  has_configured_firewall = (length(local.allowed_ips) > 0 || length(var.virtual_network_subnet_ids) > 0)
  
  tags = merge(
    var.required_tags,
    var.optional_tags
  )
}
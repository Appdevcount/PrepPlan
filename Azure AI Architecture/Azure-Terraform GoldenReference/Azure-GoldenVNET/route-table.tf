#using locals https://developer.hashicorp.com/terraform/tutorials/configuration-language/locals
locals {
  name_suffix = format("%s%s%s%s", var.location, "-", var.application, var.routetable_suffix_name)
  
  tenant_firewall_ips      = lookup(var.firewall_ip_address, data.azurerm_client_config.current.tenant_id)
  environment_firewall_ips = lookup(local.tenant_firewall_ips, local.environment_type)
  firewall_ip_address      = lookup(local.environment_firewall_ips, var.location, "") 
  allowed_routes = {
    databricks = anytrue([for rt in var.subnets : rt.routetable_databricks]) // setting this to true will add databricks routes
    firewall   = anytrue([for rt in var.subnets : rt.routetable_firewall])  // setting this to true will add firewall routes
    apim       = anytrue([for rt in var.subnets : rt.routetable_apim])      // setting this to true will add apim routes
    ms_egress  = anytrue([for rt in var.subnets : rt.routetable_microsoft])  // setting this to true will add MS EGRESS routes
    sqlmi      = anytrue([for rt in var.subnets : rt.routetable_sqlmi]) // setting this to true will add SQL MI Routes
  }
}


resource "azurerm_route_table" "firewall_routes" {
  count                         = local.allowed_routes.firewall == true ? 1 : 0
  name                          = local.name_suffix
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.target_rg.name
  disable_bgp_route_propagation = false

  route {
    name                   = "FirewallDefaultRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.firewall_ip_address
  }

  tags = local.tags

  lifecycle {

    precondition {
      condition     = local.allowed_routes.firewall == true ? length(local.firewall_ip_address) > 0 : true
      error_message = "Firewall IP address is required when creating firewall route table."
    }
    precondition {
      condition     = local.allowed_routes.firewall == true ? data.azurerm_client_config.current.tenant_id != "595de295-db43-4c19-8b50-183dfd4a3d06" : true
      error_message = "The default Firewall Route Table is not available for eviCore tenant. The routetable_firewall property for all subnets should be set to false."
    }

    ignore_changes = [
      tags["createdBy"],
      tags["CreatedDate"],
      tags["createdDateTime"],
      tags["Environment"],
    ]
  }
}


# The var.subnets.routetable_fw value set to 'true' will prevent this route table association
resource "azurerm_subnet_route_table_association" "firewall_routes_association" {
  depends_on = [azurerm_route_table.firewall_routes]
  for_each = {
    for k, v in var.subnets : k => v
    if v.routetable_firewall == true
  }

  subnet_id      = azurerm_subnet.goldenVNET_sub[each.key].id
  route_table_id = azurerm_route_table.firewall_routes[0].id
}

# Azure Databricks
# Source: https://docs.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/udr


resource "azurerm_route_table" "databricks_routes" {
  count                         = local.allowed_routes.databricks == true ? 1 : 0
  name                          = format("%s%s", local.name_suffix, var.routetable_databricks_suffix_name)
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.target_rg.name
  disable_bgp_route_propagation = false

  /*route {
    name           = "ControlPlaneNATIP1"
    address_prefix = "23.101.152.95/32"
    next_hop_type  = "Internet"
  }
  route {
    name           = "ControlPlaneNATIP2"
    address_prefix = "20.41.4.112/32"
    next_hop_type  = "Internet"
  }
  route {
    name           = "WebappIP1"
    address_prefix = "40.70.58.221/32"
    next_hop_type  = "Internet"
  }

  route {
    name           = "WebappIP2"
    address_prefix = "20.41.4.113/32"
    next_hop_type  = "Internet"
  }

  route {
    name           = "ExtendedInfrastructureIP"
    address_prefix = "20.57.106.0/28"
    next_hop_type  = "Internet"
  }*/
      # https://learn.microsoft.com/en-us/azure/databricks/security/network/classic/udr#ip-addresses
  route {
    name           = "DataBricks_ControlPlane"
    address_prefix = "AzureDatabricks"
    next_hop_type  = "Internet"
  }
  route {
    name                        = "MetaStore"
    address_prefix              = "Sql.CentralUS" // "Sql.EastUS2" for east us2
    next_hop_type               = "Internet"      
  }
  route {
    name                        = "Storage"
    address_prefix              = "Storage.CentralUS" // "Storage.EastUS2" for east us2
    next_hop_type               = "Internet"
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      tags["createdBy"],
      tags["CreatedDate"],
      tags["createdDateTime"],
      tags["Environment"],
    ]
  }
}

resource "azurerm_subnet_route_table_association" "databricks_routes_association" {
  for_each = {
    for k, i in var.subnets : k => i
    if i.routetable_databricks == true 
  }
  subnet_id      = azurerm_subnet.goldenVNET_sub[each.key].id
  route_table_id = azurerm_route_table.databricks_routes[0].id
}


# Azure API Manager
# https://learn.microsoft.com/en-us/azure/api-management/virtual-network-reference?tabs=stv2
#https://techcommunity.microsoft.com/t5/azure-paas-blog/api-management-networking-faqs-demystifying-series-ii/ba-p/1502056#b1
#https://learn.microsoft.com/en-us/azure/api-management/virtual-network-reference?tabs=stv2#control-plane-ip-addresses

resource "azurerm_route_table" "apim_routes" {
  count                         = local.allowed_routes.apim == true ? 1 : 0
  name                          = format("%s%s", local.name_suffix, var.routetable_apim_suffix_name)
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.target_rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "APIManagmentControlPlaneIP_allow"
    address_prefix = format("%s%s%s", "ApiManagement", ".", var.location)
    next_hop_type  = "Internet"
  }
  tags = local.tags

  lifecycle {
    ignore_changes = [
      tags["createdBy"],
      tags["CreatedDate"],
      tags["createdDateTime"],
      tags["Environment"],
    ]
  }
}

resource "azurerm_subnet_route_table_association" "apim_routes_association" {
  for_each = {
    for k, l in var.subnets : k => l
    if l.routetable_apim == true 
  }
  subnet_id      = azurerm_subnet.goldenVNET_sub[each.key].id
  route_table_id = azurerm_route_table.apim_routes[0].id
}

# Microsoft for all Internet egress
# Services: App Service Environments v2

resource "azurerm_route_table" "microsoft_internet_routes" {
  count                         = local.allowed_routes.ms_egress == true ? 1 : 0
  name                          = format("%s%s", local.name_suffix, var.routetable_microsoft_suffix_name)
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.target_rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "MicrosoftDefaultRoute"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      tags["createdBy"],
      tags["CreatedDate"],
      tags["createdDateTime"],
      tags["Environment"],
    ]
  }
}
resource "azurerm_subnet_route_table_association" "microsoft_internet_routes_association" {
  for_each = {
    for k, n in var.subnets : k => n
    if n.routetable_microsoft == true 
  }
  subnet_id      = azurerm_subnet.goldenVNET_sub[each.key].id
  route_table_id = azurerm_route_table.microsoft_internet_routes[0].id
}


# SQL MI Route Tables

resource "azurerm_route_table" "sqlmi_routes" {
  count                         = local.allowed_routes.sqlmi == true ? 1 : 0
  name                          = "${local.name_suffix}-sqlmi"
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.target_rg.name
  disable_bgp_route_propagation = false

  dynamic "route" {
    for_each = var.vnetcidr

    content {
      name = "Microsoft.Sql-managedInstances_UseOnly_mi-Vnet-local-${replace(route.value, "/", "_")}"
      address_prefix = route.value
      next_hop_type = "VnetLocal"
    }
  }

  route {
    name           = "Microsoft.Sql-managedInstances_UseOnly_mi-Storage"
    address_prefix = "Storage"
    next_hop_type  = "Internet"
  }
  route {
    name           = "Microsoft.Sql-managedInstances_UseOnly_mi-SqlManagement"
    address_prefix = "SqlManagement"
    next_hop_type  = "Internet"
  }
  route {
    name           = "Microsoft.Sql-managedInstances_UseOnly_mi-AzureMonitor"
    address_prefix = "AzureMonitor"
    next_hop_type  = "Internet"
  }
  route {
    name           = "Microsoft.Sql-managedInstances_UseOnly_mi-CorpNetSaw"
    address_prefix = "CorpNetSaw"
    next_hop_type  = "Internet"
  }
  route {
    name           = "Microsoft.Sql-managedInstances_UseOnly_mi-CorpNetPublic"
    address_prefix = "CorpNetPublic"
    next_hop_type  = "Internet"
  }
  route {
    name           = "Microsoft.Sql-managedInstances_UseOnly_mi-AzureActiveDirectory"
    address_prefix = "AzureActiveDirectory"
    next_hop_type  = "Internet"
  }
  route {
    name           = "Microsoft.Sql-managedInstances_UseOnly_mi-AzureCloud.eastus2"
    address_prefix = "AzureCloud.eastus2"
    next_hop_type  = "Internet"
  }
  route {
    name           = "Microsoft.Sql-managedInstances_UseOnly_mi-AzureCloud.centralus"
    address_prefix = "AzureCloud.centralus"
    next_hop_type  = "Internet"
  }
  route {
    name           = "Microsoft.Sql-managedInstances_UseOnly_mi-Storage.eastus2"
    address_prefix = "Storage.eastus2"
    next_hop_type  = "Internet"
  }
  route {
    name           = "Microsoft.Sql-managedInstances_UseOnly_mi-Storage.centralus"
    address_prefix = "Storage.centralus"
    next_hop_type  = "Internet"
  }
  route {
    name           = "Microsoft.Sql-managedInstances_UseOnly_mi-EventHub.eastus2"
    address_prefix = "EventHub.eastus2"
    next_hop_type  = "Internet"
  }
  route {
    name           = "Microsoft.Sql-managedInstances_UseOnly_mi-EventHub.centralus"
    address_prefix = "EventHub.centralus"
    next_hop_type  = "Internet"
  }

 tags = local.tags

  lifecycle {
    ignore_changes = [
      tags["createdBy"],
      tags["CreatedDate"],
      tags["createdDateTime"],
      tags["Environment"],
    ]
  }
}

resource "azurerm_subnet_route_table_association" "sqlmi_routes_association" {
  for_each = {
    for k, l in var.subnets : k => l
    if l.routetable_sqlmi == true 
  }
  subnet_id      = azurerm_subnet.goldenVNET_sub[each.key].id
  route_table_id = azurerm_route_table.sqlmi_routes[0].id
}

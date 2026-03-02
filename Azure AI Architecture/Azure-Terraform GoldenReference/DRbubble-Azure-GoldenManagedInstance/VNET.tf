# Create security group
resource "azurerm_network_security_group" "network_security_group" {
  name                = "${local.naming_prefix}-nsg"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  tags = local.tags
}

#Pull in subnet from VNET Golden Module
data "azurerm_subnet" "subnet" {
  name                 = var.instance_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
}

# Associate subnet and the security group
resource "azurerm_subnet_network_security_group_association" "subnet_network_security_group_association" {
  subnet_id                 = data.azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.network_security_group.id
}

# Create a route table
resource "azurerm_route_table" "route_table" {
  name                          = "${local.naming_prefix}-rt"
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = true

  tags = local.tags
}

# Associate subnet and the route table
resource "azurerm_subnet_route_table_association" "subnet_route_table_association" {
  subnet_id      = data.azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.route_table.id

  depends_on = [azurerm_subnet_network_security_group_association.subnet_network_security_group_association]
}

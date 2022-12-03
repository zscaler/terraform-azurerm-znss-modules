#-------------------------------
# Azure Virtual Network
#-------------------------------
resource "azurerm_virtual_network" "this" {
  count = var.create_virtual_network ? 1 : 0

  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

#-------------------------------
# Azure Data Virtual Network
#-------------------------------
data "azurerm_virtual_network" "this" {
  count = var.create_virtual_network == false ? 1 : 0

  resource_group_name = var.resource_group_name
  name                = var.virtual_network_name
}

locals {
  virtual_network = var.create_virtual_network ? azurerm_virtual_network.this[0] : data.azurerm_virtual_network.this[0]
}

#-----------------------
# Azure Subnets
#-----------------------
resource "azurerm_subnet" "this" {
  for_each = { for k, v in var.subnets : k => v if var.create_subnets }

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = each.value.address_prefixes
}

# ---------------------------
# Azure Subnet Data
# ---------------------------
data "azurerm_subnet" "this" {
  for_each = { for k, v in var.subnets : k => v if var.create_subnets == false }

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = local.virtual_network.name
}

#-------------------------------
# Azure Network Security Group
#-------------------------------
resource "azurerm_network_security_group" "this" {
  for_each = var.network_security_groups

  name                = each.key
  location            = try(each.value.location, var.location)
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

locals {
  nsg_rules = flatten([
    for nsg_name, nsg in var.network_security_groups : [
      for rule_name, rule in lookup(nsg, "rules", {}) : {
        nsg_name = nsg_name
        name     = rule_name
        rule     = rule
      }
    ]
  ])
}

#-------------------------------
# Azure Network Security Group Rule
#-------------------------------
resource "azurerm_network_security_rule" "this" {
  for_each = {
    for nsg in local.nsg_rules : "${nsg.nsg_name}-${nsg.name}" => nsg
  }

  name                         = each.value.name
  resource_group_name          = var.resource_group_name
  network_security_group_name  = azurerm_network_security_group.this[each.value.nsg_name].name
  priority                     = each.value.rule.priority
  direction                    = each.value.rule.direction
  access                       = each.value.rule.access
  protocol                     = each.value.rule.protocol
  source_port_range            = each.value.rule.source_port_range
  destination_port_range       = each.value.rule.destination_port_range
  source_address_prefix        = lookup(each.value.rule, "source_address_prefix", null)
  source_address_prefixes      = lookup(each.value.rule, "source_address_prefixes", null)
  destination_address_prefix   = lookup(each.value.rule, "destination_address_prefix", null)
  destination_address_prefixes = lookup(each.value.rule, "destination_address_prefixes", null)

  depends_on = [azurerm_network_security_group.this]
}

#------------------------------------------------------
# Azure Route table and rules
#------------------------------------------------------
resource "azurerm_route_table" "this" {
  for_each = var.route_tables

  name                = each.key
  location            = try(each.value.location, var.location)
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

locals {
  route = flatten([
    for route_table_name, route_table in var.route_tables : [
      for route_name, route in route_table.routes : {
        route_table_name = route_table_name
        name             = route_name
        route            = route
      }
    ]
  ])
}

resource "azurerm_route" "this" {
  for_each = {
    for route in local.route : "${route.route_table_name}-${route.name}" => route
  }

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.this[each.value.route_table_name].name
  address_prefix         = each.value.route.address_prefix
  next_hop_type          = each.value.route.next_hop_type
  next_hop_in_ip_address = try(each.value.route.next_hop_in_ip_address, null)
}

# ------------------------------------------------------
# Azure NAT Gateway
# ------------------------------------------------------
resource "azurerm_public_ip_prefix" "this" {
  name                = "ng-${var.ip_prefix_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  prefix_length       = 30
  zones               = ["1"]
}

resource "azurerm_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1 : 0

  name                    = "ng${var.nat_gateway_name}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

# ------------------------------------------------------
# Azure Data NAT Gateway
# ------------------------------------------------------
data "azurerm_nat_gateway" "this" {
  count = var.create_nat_gateway == false ? 1 : 0

  name                = "ng${var.nat_gateway_name}"
  resource_group_name = var.resource_group_name
}

# ------------------------------------------------------
# Azure NAT Gateway integration with IP prefix
# ------------------------------------------------------
resource "azurerm_nat_gateway_public_ip_prefix_association" "this" {
  nat_gateway_id      = var.create_nat_gateway ? azurerm_nat_gateway.this[0].id : data.azurerm_nat_gateway.this[0].id
  public_ip_prefix_id = azurerm_public_ip_prefix.this.id
}

# ------------------------------------------------------
# Azure NAT Gateway integration with Subnets
# ------------------------------------------------------
resource "azurerm_subnet_nat_gateway_association" "this" {
  for_each = var.subnets

  nat_gateway_id = var.create_nat_gateway ? azurerm_nat_gateway.this[0].id : data.azurerm_nat_gateway.this[0].id
  subnet_id      = var.create_subnets ? azurerm_subnet.this[each.key].id : data.azurerm_subnet.this[each.key].id
}

#-------------------------------------------------------
# Azure Network Security Group Integration with Subnets
#-------------------------------------------------------
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = { for k, v in var.subnets : k => v if lookup(v, "network_security_group", "") != "" }

  subnet_id                 = var.create_subnets ? azurerm_subnet.this[each.key].id : data.azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.value.network_security_group].id
}
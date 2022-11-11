output "resource_group_name" {
  description = "The name of the Resource Group."
  value       = var.create_resource_group ? azurerm_resource_group.this[0].name : data.azurerm_resource_group.this[0].name
}

output "resource_group_id" {
  description = "The identifier of the Resource Group."
  value       = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.this[0].id
}

output "resource_group_location" {
  description = "The location of the Resource Group."
  value       = var.create_resource_group ? azurerm_resource_group.this[0].location : data.azurerm_resource_group.this[0].location

}

output "virtual_network_id" {
  description = "The identifier of the created Virtual Network."
  value       = module.vnet.virtual_network_id
}

output "subnet_ids" {
  description = "The identifiers of the created Subnets."
  value       = module.vnet.subnet_ids
}

output "network_security_group_ids" {
  description = "The identifiers of the created Network Security Groups."
  value       = module.vnet.network_security_group_ids
}

output "route_table_id" {
  description = "The identifier of the created Route Tables."
  value       = module.vnet.route_table_ids
}

#---------------------------------------------------------------
# Azure Resource Group Deployment
#----------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ---------------------------------------------------------------
# Data Resource Group 
#---------------------------------------------------------------
data "azurerm_resource_group" "this" {
  count = var.create_resource_group == false ? 1 : 0
  name = var.resource_group_name
}

#---------------------------------------------------------------
# Module for Virtual Network,Subnets and Security Group
#----------------------------------------------------------------
module "vnet" {
  source = "../../modules/vnet"

  virtual_network_name    = var.virtual_network_name
  resource_group_name     = var.resource_group_name
  location                = var.location
  address_space           = var.address_space
  network_security_groups = var.network_security_groups
  route_tables            = var.route_tables
  subnets                 = var.subnets
  nat_gateway_name        = var.nat_gateway_name
  ip_prefix_name          = var.ip_prefix_name
  create_nat_gateway      = var.create_nat_gateway
  create_subnets          = var.create_subnets
  create_virtual_network  = var.create_virtual_network
  tags                    = var.tags
  depends_on = [
    azurerm_resource_group.this,
    data.azurerm_resource_group.this
  ]
}

#---------------------------------------------------------------
# Module for Storage, Automation Account and Copy VHD
#----------------------------------------------------------------
module "bootstrap" {
  source = "../../modules/bootstrap"

  resource_group_name     = var.resource_group_name
  location                = var.location
  create_storage_account  = var.create_storage_account
  storage_account_name    = var.storage_account_name
  containers_name         = var.containers_name
  blob_name               = var.blob_name
  osdisk                  = var.osdisk
  sastok                  = var.sastok
  automation_account_name = var.automation_account_name
  copy_vhd_url            = var.copy_vhd_url
  asset_container_name    = var.asset_container_name
  file_to_copy            = var.file_to_copy
  depends_on = [
    module.vnet
  ]
}

#---------------------------------------------------------------
# Module for Virtual Machine and dependent resources deployment
#----------------------------------------------------------------
module "vm-znss" {
  source = "../../modules/vm-znss"

  location             = var.location
  resource_group_name  = var.resource_group_name
  name                 = var.vm_name
  avzones              = var.avzones
  storage_account_name = var.storage_account_name
  containers_name      = var.containers_name
  blob_name            = var.blob_name
  admin_username       = var.admin_username
  admin_password       = var.admin_password
  container_uri        = module.bootstrap.webhookurlcontainerfile
  asset_container_name = var.asset_container_name
  file_to_copy         = var.file_to_copy
  is_system_windows    = var.is_system_windows
  nat_public_ip        = module.vnet.nat_public_ip
  interfaces = [
    {
      name             = var.mgmt_nic_name
      subnet_id        = lookup(module.vnet.subnet_ids, "public", null)
      create_public_ip = var.make_mgmt_private ? false : true
    },
    {
      name             = var.srvc_nic_name
      subnet_id        = lookup(module.vnet.subnet_ids, "public", null)
      create_public_ip = false
    },
  ]
  depends_on = [
    module.bootstrap
  ]
}

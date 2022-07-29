#---------------------------------------------------------------
# Azure Resource Group Deployment
#----------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

#---------------------------------------------------------------
# Module for Virtual Network,Subnets and Security Group
#----------------------------------------------------------------
module "vnet" {
  source = "../../modules/vnet"

  virtual_network_name    = var.virtual_network_name
  resource_group_name     = azurerm_resource_group.this.name
  location                = var.location
  address_space           = var.address_space
  network_security_groups = var.network_security_groups
  route_tables            = var.route_tables
  subnets                 = var.subnets
  tags                    = var.tags
}

#---------------------------------------------------------------
# Module for Storage, Automation Account and Copy VHD
#----------------------------------------------------------------
module "bootstrap" {
  source = "../../modules/bootstrap"

  resource_group_name  = azurerm_resource_group.this.name
  location             = azurerm_resource_group.this.location
  storage_account_name = var.storage_account_name
  containers_name      = var.containers_name
  blob_name            = var.blob_name
  osdisk               = var.osdisk
  sastok               = var.sastok
  automation_account_name = var.automation_account_name
  copy_vhd_url         = var.copy_vhd_url
  depends_on = [
    module.vnet
  ]
}

#---------------------------------------------------------------
# Module for Virtual Machine and dependent resources deployment
#----------------------------------------------------------------
module "vm-znss" {
  source = "../../modules/vm-znss"

  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  name                = var.vm_name
  avzones             = var.avzones
  storage_account_name = var.storage_account_name
  containers_name      = var.containers_name
  blob_name            = var.blob_name
  interfaces = [
    {
      name             = "Zscaler-NSS-MGMT-First"
      subnet_id        = lookup(module.vnet.subnet_ids, "public", null)
      create_public_ip = true
    },
    {
      name             = "Zscaler-NSS-MGMT-Sec"
      subnet_id        = lookup(module.vnet.subnet_ids, "public", null)
      create_public_ip = true
    },
  ]
  depends_on = [
    module.bootstrap
  ]
}

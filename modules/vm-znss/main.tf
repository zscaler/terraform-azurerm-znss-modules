#-------------------------------
# Azure Public IP
#-------------------------------
resource "azurerm_public_ip" "this" {
  for_each = { for k, v in var.interfaces : k => v if try(v.create_public_ip, false) }

  location            = var.location
  resource_group_name = var.resource_group_name
  name                = each.value.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.enable_zones ? var.avzones : null
  tags                = try(each.value.tags, var.tags)
}

#-------------------------------
# Azure Network Interfaces
#-------------------------------
resource "azurerm_network_interface" "this" {
  count = length(var.interfaces)

  name                          = var.interfaces[count.index].name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = count.index == 0 ? false : var.accelerated_networking
  enable_ip_forwarding          = try(var.interfaces[count.index].enable_ip_forwarding, count.index == 0 ? false : true)
  tags                          = try(var.interfaces[count.index].tags, var.tags)

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.interfaces[count.index].subnet_id
    private_ip_address_allocation = try(var.interfaces[count.index].private_ip_address, null) != null ? "Static" : "Dynamic"
    private_ip_address            = try(var.interfaces[count.index].private_ip_address, null)
    public_ip_address_id          = try(azurerm_public_ip.this[count.index].id, var.interfaces[count.index].public_ip_address_id, null)
  }
  depends_on = [
    azurerm_public_ip.this
  ]
}

#-------------------------------
# Delay in deployment
#-------------------------------
resource "null_resource" "before" {
}

#waiting time for disk to get copied
resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "start-sleep 1800"
    interpreter = ["pwsh", "-Command"]
  }
  triggers = {
    "before" = "${null_resource.before.id}"
  }
}

#-------------------------------
# Azure Virtual Machine
#-------------------------------
resource "azurerm_virtual_machine" "this" {
  name                             = "${var.resource_group_name}-vm"
  location                         = var.location
  resource_group_name              = var.resource_group_name
  vm_size                          = var.vm_size
  availability_set_id              = var.avset_id
  primary_network_interface_id     = azurerm_network_interface.this[0].id

  network_interface_ids = [for k, v in azurerm_network_interface.this : v.id]

  storage_os_disk {
    create_option     = "Attach"
    name              = "${var.resource_group_name}_osdisk.vhd"
    os_type           = "Linux"
    vhd_uri           = "https://${var.storage_account_name}.blob.core.windows.net/${var.containers_name}/${var.blob_name}"
    disk_size_gb      = "600"
    caching           = "ReadWrite"
  }
  delete_os_disk_on_termination    = true
  dynamic "boot_diagnostics" {
    for_each = var.diagnostics_storage_uri != null ? ["one"] : []

    content {
      enabled     = true
      storage_uri = var.diagnostics_storage_uri
    }
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }
  depends_on = [
    null_resource.delay
  ]
}

#-------------------------------
# Azure App Insight
#-------------------------------
resource "azurerm_application_insights" "this" {
  count = var.metrics_retention_in_days != 0 ? 1 : 0

  name                = coalesce(var.name_application_insights, var.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "other"
  retention_in_days   = var.metrics_retention_in_days
  tags                = var.tags
}


resource_group_name  = "RG-ZNSS01"
location             = "Canada Central"
virtual_network_name = "znss-vnet-a"
address_space        = ["192.168.100.0/24"]
network_security_groups = {
  "network_security_group_1" = {
    location = "Canada Central"
    rules = {
      "z-ssh-rule" = {
        priority                   = 101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "z-smca-rule" = {
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "9422"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "z-remotesupport-rule" = {
        priority                   = 102
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "12002"
        source_address_prefix      = "*"
        destination_address_prefix = "199.168.148.0/24"
      },
      "z-nanolog-rule" = {
        priority                   = 103
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "9431"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "z-dns-rule" = {
        priority                   = 104
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "53"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "z-ntp-rule" = {
        priority                   = 105
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "123"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "z-cdss-rule" = {
        priority                   = 106
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
    }
  },
}
route_tables = {
  "route_table_1" = {
    routes = {
      "route_1" = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "192.168.100.100"
      },
    }
  },
}
subnets = {
  "public" = {
    address_prefixes       = ["192.168.100.0/25"]
    network_security_group = "network_security_group_1"
    route_table            = "route_table_1"
  },
}
tags = {
  env      = "production",
  provider = "zscaler"
}

storage_account_name = "znssstorage20221202"
containers_name      = "znss"
blob_name            = "znss_osdisk.vhd"
automation_account_name = "znssautomationaccount"
copy_vhd_url = "https://raw.githubusercontent.com/zscaler/terraform-azurerm-znss-modules/master/scripts/copyvhd.ps1"
vm_name              = "Zscaler-NSS-VM01"
avzones = ["1", "2", "3"]
osdisk = "https://zsprod.blob.core.windows.net/nss/znss_5_1_osdisk.vhd"
sastok = "?sv=2019-02-02&ss=b&srt=sco&sp=rl&se=2023-03-12T09:20:42Z&st=2020-03-12T00:20:42Z&spr=https&sig=p6OHCAv5Rxax9i1F%2BLaYBDmvUNI64VZGtDHcm9CsE0Y%3D"
mgmt_nic_name = "Zscaler-NSS-MGMT-NIC01"
srvc_nic_name = "Zscaler-NSS-SRVC-NIC01"
nat_gateway_name = "ZNSS-NAT-GW01"
ip_prefix_name = "IP_PREFIX_01"
pswd_auth = true

# Add virtual machine credentials here!!!
admin_username = "zsroot"
admin_password = "zsroot"
asset_container_name = "assets"
file_to_copy = "NssCertificate.zip"
create_virtual_network = true
create_subnets = true
make_mgmt_private = false
create_nat_gateway = true
create_resource_group = true
create_storage_account = true

resource_group_name  = "RG-Canada"
location             = "Canada Central"
virtual_network_name = "example-vnet-b"
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
  env      = "example",
  provider = "terraform"
}

storage_account_name    = "znssstg08132021"
containers_name         = "znss"
blob_name               = "znss_osdisk.vhd"
automation_account_name = "autaccounttest"
copy_vhd_url            = "https://raw.githubusercontent.com/zscaler/nss-azure-deploy/master/scripts/copyvhd.ps1"
vm_name                 = "Zscaler-NSS-VM"
avzones                 = ["1", "2", "3"]
osdisk                  = "https://zsprod.blob.core.windows.net/nss/znss_5_0_osdisk.vhd"
sastok                  = "?sv=2019-02-02&ss=b&srt=sco&sp=rl&se=2023-03-12T09:20:42Z&st=2020-03-12T00:20:42Z&spr=https&sig=p6OHCAv5Rxax9i1F%2BLaYBDmvUNI64VZGtDHcm9CsE0Y%3D"
mgmt_nic_name           = "Zscaler-NSS-MGMT-NIC"
srvc_nic_name           = "Zscaler-NSS-SRVC-NIC"
nat_gateway_name        = "nat_gateway_1"
ip_prefix_name          = "ip_prefix_1"
pswd_auth               = true

# Add virtual machine credentials here!!!
# These are test credentials and should be replaced with real ones prior to running the template
admin_username       = "zsroot"
admin_password       = "zsroot"
asset_container_name = "assets"
file_to_copy         = "NssCertificate.zip"
/*
is_system_windows = false  // For Linux or MacOS
CASE 1: Linux
  sudo apt-get install sshpass

CASE 2: MacOS
  curl -L https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb > sshpass.rb && brew install sshpass.rb && rm sshpass.rb
*/
is_system_windows = false
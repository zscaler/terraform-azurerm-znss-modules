resource_group_name  = "example-rg"
location             = "Canada Central"
virtual_network_name = "example-vnet"
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

storage_account_name = "znssvhdstorage"
containers_name      = "zscalernssrprod"
blob_name            = "znss_osdisk.vhd"
automation_account_name = "VHDcopy-Automation"
copy_vhd_url = "https://raw.githubusercontent.com/zscaler/terraform-azurerm-znss-modules/master/scripts/copyvhd.ps1"
vm_name              = "Zscaler-NSS-VM"
avzones = ["1", "2", "3"]
osdisk = "https://zsprod.blob.core.windows.net/nss/znss_5_0_osdisk.vhd"

# https://help.zscaler.com/zia/nss-deployment-guide-microsoft-azure
# Before you begin deployment, contact Zscaler Support to obtain the NSS VHD SAS token and the Azure VM instance type recommendations.
# Pass the SAS Token required for authentication into the source storage account.
sastok = ""


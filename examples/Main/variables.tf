variable "virtual_network_name" {
  description = "The name of the VNet to create."
  type        = string
}

variable "location" {
  description = "Location of the resources that will be deployed."
  type        = string
}

variable "tags" {
  description = "Map of tags to assign to all of the created resources."
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Name of the Resource Group to create."
  type        = string
}

variable "address_space" {
  description = "The address space used by the virtual network. You can supply more than one address space."
  type        = list(string)
}

variable "pswd_auth" {
  type = bool
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type = string
}

variable "is_system_windows" {
  type = bool
}

variable "create_subnets" {
  description = "If true, create the Subnets, otherwise just use a pre-existing network."
  default     = true
  type        = bool
}

variable "create_nat_gateway" {
  description = "If true, create the NAT Gateway, otherwise just use a pre-existing network."
  default     = true
  type        = bool
}

variable "make_mgmt_private" {
  description = "If true, create the Private Subnets, otherwise just use a pre-existing network."
  default     = false
  type        = bool
}

variable "create_virtual_network" {
  description = "If true, create the Virtual Network, otherwise just use a pre-existing network."
  default     = true
  type        = bool
}

variable "create_resource_group" {
  description = "If true, create the Resource Group, otherwise just use a pre-existing network."
  default     = true
  type        = bool
}

variable "create_storage_account" {
  description = "If true, create the Storage Account, otherwise just use a pre-existing network."
  default     = true
  type        = bool
}

variable "network_security_groups" {
  description = <<-EOF
  Map of Network Security Groups to create. The key of each entry acts as the Network Security Group name.
  List of available attributes of each Network Security Group entry:
  - `location` : (Optional) Specifies the Azure location where to deploy the resource.
  - `rules`: A list of objects representing a Network Security Rule. The key of each entry acts as the name of the rule and
      needs to be unique across all rules in the Network Security Group.
      List of attributes available to define a Network Security Rule:
      - `priority` : Numeric priority of the rule. The value can be between 100 and 4096 and must be unique for each rule in the collection.
      The lower the priority number, the higher the priority of the rule.
      - `direction` : The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are `Inbound` and `Outbound`.
      - `access` : Specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`.
      - `protocol` : Network protocol this rule applies to. Possible values include `Tcp`, `Udp`, `Icmp`, or `*` (which matches all).
      - `source_port_range` : List of source ports or port ranges.
      - `destination_port_range` : Destination Port or Range. Integer or range between `0` and `65535` or `*` to match any.
      - `source_address_prefix` : List of source address prefixes. Tags may not be used.
      - `destination_address_prefix` : CIDR or destination IP range or `*` to match any IP.

  Example:
  ```
  {
    "network_security_group_1" = {
      location = "Australia Central"
      rules = {
        "AllOutbound" = {
          priority                   = 100
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        "AllowSSH" = {
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }
    },
    "network_security_group_2" = {
      rules = {}
    }
  }
  ```
  EOF
}

variable "route_tables" {
  description = <<-EOF
  Map of objects describing a Route Table. The key of each entry acts as the Route Table name.
  List of available attributes of each Route Table entry:
  - `location` : (Optional) Specifies the Azure location where to deploy the resource.
  - `routes` : (Optional) Map of routes within the Route Table.
    List of available attributes of each route entry:
    - `address_prefix` : The destination CIDR to which the route applies, such as `10.1.0.0/16`.
    - `next_hop_type` : The type of Azure hop the packet should be sent to.
      Possible values are: `VirtualNetworkGateway`, `VnetLocal`, `Internet`, `VirtualAppliance` and `None`.
    - `next_hop_in_ip_address` : Contains the IP address packets should be forwarded to.
      Next hop values are only allowed in routes where the next hop type is `VirtualAppliance`.

  Example:
  ```
  {
    "route_table_1" = {
      routes = {
        "route_1" = {
          address_prefix = "10.1.0.0/16"
          next_hop_type  = "vnetlocal"
        },
        "route_2" = {
          address_prefix = "10.2.0.0/16"
          next_hop_type  = "vnetlocal"
        },
      }
    },
    "route_table_2" = {
      routes = {
        "route_3" = {
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.112.0.100"
        }
      },
    },
  }
  ```
  EOF
}

variable "subnets" {
  description = <<-EOF
  Map of subnet objects to create within a virtual network. The key of each entry acts as the subnet name.
  List of available attributes of each subnet entry:
  - `address_prefixes` : The address prefix to use for the subnet.
  - `network_security_group_id` : The Network Security Group identifier to associate with the subnet.
  - `route_table_id` : The Route Table identifier to associate with the subnet.
  - `tags` : (Optional) Map of tags to assign to the resource.

  Example:
  ```
  {
    "management" = {
      address_prefixes       = ["10.100.0.0/24"]
      network_security_group = "network_security_group_1"
      route_table            = "route_table_1"
    },
    "private" = {
      address_prefixes       = ["10.100.1.0/24"]
      network_security_group = "network_security_group_2"
      route_table            = "route_table_2"
    },
    "public" = {
      address_prefixes       = ["10.100.2.0/24"]
      network_security_group = "network_security_group_3"
      route_table            = "route_table_3"
    },
  }
  ```
  EOF
}


variable "storage_account_name" {
  description = <<-EOF
  Default name of the storage account to create.
  The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters.
  EOF
  default     = "znssstorage"
  type        = string
}

variable "containers_name" {
  description = "The name of the container in the storage account."
  type        = string
}

variable "blob_name" {
  type = string
}

variable "osdisk" {
  type = string
}

variable "sastok" {
  type = string
}

variable "automation_account_name" {
  type = string
}

variable "copy_vhd_url" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "avzones" {
  description = <<-EOF
  After provider version 3.x you need to specify in which availability zone(s) you want to place IP.
  ie: for zone-redundant with 3 availability zone in current region value will be:
  ```["1","2","3"]```
  Use command ```az vm list-skus --location REGION_NAME --zone --query '[0].locationInfo[0].zones'``` to see how many AZ is
  in current region.
  EOF
  default     = []
  type        = list(string)
}

variable "mgmt_nic_name" {
  type    = string
  default = "Zscaler-NSS-MGMT-NIC"
}

variable "srvc_nic_name" {
  type    = string
  default = "Zscaler-NSS-SRVC-NIC"
}

variable "nat_gateway_name" {
  description = "The name of the NAT Gateway to create."
  type        = string
  default     = "nat_gateway_1"
}

variable "ip_prefix_name" {
  description = "The name of the ip prefix  to create."
  type        = string
  default     = "ip_prefix_1"
}

variable "asset_container_name" {
  description = "The name of the container for storing zip file from assets folder"
  type        = string
  default     = "assets"
}

variable "file_to_copy" {
  description = "The name of the file to copy inside virtual machine"
  type        = string
  default     = "TestFolder.zip"
}

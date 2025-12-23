variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region (e.g., westeurope)"
  type        = string
}

variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
}

variable "address_space" {
  description = "VNet address space (e.g., 10.0.0.0/16)"
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnets to create (Name -> Prefix)"
  type        = map(string)
  default = {
    "snet-frontend" = "10.0.1.0/24"
    "snet-backend"  = "10.0.2.0/24"
    "snet-db"       = "10.0.3.0/24"
  }
}
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

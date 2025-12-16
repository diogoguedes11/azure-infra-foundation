variable "create_public_ip" {
  description = "Whether to create and attach a public IP to the VM"
  type        = bool
  default     = false
}
variable "prefix" {
  description = "VM name prefix"
  type        = string
}

variable "location" {
  description = "VM location"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name where resources will be created"
  type        = string
}
variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
  default     = "Standard_DS1_v2"
}
variable "virtual_network_name" {
  description = "virtual machine name"
  type        = string
}
variable "admin_password" {
  type        = string
  description = "A password that comes from Key vault"
  sensitive   = true
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region (e.g., westeurope)"
  type        = string
}

variable "vm_id" {
  description = "The ID of the virtual machine to be backed up"
  type        = string
}

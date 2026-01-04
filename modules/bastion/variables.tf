variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
}
variable "location" {
  description = "The location for the bastion"
}

variable "common_tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
variable "subnet_id" {
  description = "The ID of the subnet where the bastion will be deployed."
  type        = string
}

variable "virtual_network_id" {
  description = "The ID of the virtual network where the bastion will be deployed."
  type        = string
}

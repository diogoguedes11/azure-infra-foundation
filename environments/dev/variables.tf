variable "location" {
  description = "The Azure region to deploy resources in."
  type        = string
  default     = "East US"
}
variable "admin_password" {
  description = "Admin password for the VM"
  sensitive   = true
  type        = string
}

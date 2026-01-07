variable "location" {
  default = "East US"
}
variable "admin_password" {
  sensitive = true # Esconde dos logs
}

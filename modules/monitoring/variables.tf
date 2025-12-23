variable "location" {
  description = "VM location"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name where resources will be created"
  type        = string
}


variable "alert_email" {
  description = "Alert email to be notified"
  type        = string
}

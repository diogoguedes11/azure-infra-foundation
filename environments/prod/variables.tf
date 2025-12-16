variable "resource_group_name" {
  type        = string
  description = "Resource group name"
  default     = "rg-foundation-prod"
}

variable "location" {
  type        = string
  description = "Location for all resources"
  default     = "westeurope"

}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "subscription_id" {
  type        = string
  description = "Subscription ID"
}


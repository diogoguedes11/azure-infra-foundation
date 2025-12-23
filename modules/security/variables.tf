variable "location" {
  description = "VM location"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name where resources will be created"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "key_vault_name" {
  type        = string
  description = "The name of the Key Vault"
}
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

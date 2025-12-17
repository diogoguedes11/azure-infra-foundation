output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.this.id
}
output "vm_admin_password" {
  description = "The admin password for the VM stored in Key Vault"
  value       = azurerm_key_vault_secret.main.value
}

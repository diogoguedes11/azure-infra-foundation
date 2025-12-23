output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.this.id
}
output "ssh_public_key" {
  description = "The SSH public key for VM access"
  value       = azurerm_key_vault_secret.ssh_public_key.value
}

output "vm_principal_id" {
  value       = azurerm_virtual_machine.this.identity[0].principal_id
  description = "O ID da identidade gerida da VM"
}

output "vm_principal_id" {
  value       = azurerm_linux_virtual_machine.this.identity[0].principal_id
  description = "Principal ID for the vm identity"
}

output "vm_id" {
  value       = azurerm_linux_virtual_machine.this.id
  description = "Virtual Machine ID"
}

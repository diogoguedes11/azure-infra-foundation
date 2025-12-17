output "vm_principal_id" {
  value       = azurerm_virtual_machine.primary_vm.identity[0].principal_id
  description = "Principal ID for the vm identity"
}

output "vm_id" {
  value       = azurerm_virtual_machine.primary_vm.id
  description = "Virtual Machine ID"
}

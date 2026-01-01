output "vm_principal_id" {
  value       = var.vm_scale_set ? azurerm_linux_virtual_machine_scale_set.vmss[0].identity[0].principal_id : (length(azurerm_linux_virtual_machine.this) > 0 ? azurerm_linux_virtual_machine.this[0].identity[0].principal_id : null)
  description = "Principal ID for the vm or vmss identity"
}

output "vm_id" {
  value       = var.vm_scale_set ? azurerm_linux_virtual_machine_scale_set.vmss[0].id : (length(azurerm_linux_virtual_machine.this) > 0 ? azurerm_linux_virtual_machine.this[0].id : null)
  description = "Virtual Machine ID or VMSS ID"
}

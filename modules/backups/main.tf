resource "azurerm_recovery_services_vault" "recovery_vault" {
  name                = "${var.resource_group_name}-recovery-vault"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
}

resource "azurerm_backup_policy_vm" "daily_backup_policy" {
  name                = "bkp-policy-daily-foundation"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.recovery_vault.name
  timezone            = "UTC"
  backup {
    frequency = "Daily"
    time      = "23:00"
  }
  retention_daily {
    count = 7
  }
}

resource "azurerm_backup_protected_vm" "protected_vm" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.recovery_vault.name
  source_vm_id        = var.vm_id
  backup_policy_id    = azurerm_backup_policy_vm.daily_backup_policy.id
}

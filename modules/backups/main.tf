resource "azurerm_recovery_services_vault" "this" {
  name                = "${var.resource_group_name}-recovery-vault"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
}

resource "azurerm_backup_policy_vm" "main" {
  name                = "bkp-policy-daily-foundation"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this.name
  timezone            = "UTC"
  backup {
    frequency = "Daily"
    time      = "23:00"
  }
  retention_daily {
    count = 7
  }
}

resource "azurerm_backup_protected_vm" "main" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this.name
  source_vm_id        = var.vm_id
  backup_policy_id    = azurerm_backup_policy_vm.main.id
}

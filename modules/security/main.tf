data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true

  sku_name                  = "standard"
  enable_rbac_authorization = true

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Owner       = "diogo.guedes"
  }
}

resource "random_password" "vm_admin_password" {
  length           = 20
  special          = true
  override_special = "!@#$%^&*()"
}

resource "azurerm_key_vault_secret" "admin_password_secret" {
  name         = "vm-admin-password"
  value        = random_password.vm_admin_password.result
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on   = [azurerm_role_assignment.key_vault_role]
}

resource "azurerm_role_assignment" "key_vault_role" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

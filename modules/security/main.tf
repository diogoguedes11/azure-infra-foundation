data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "this" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name                  = "standard"
  enable_rbac_authorization = true
}
resource "random_password" "vm_password" {
  length  = 16
  special = true
}


resource "azurerm_key_vault_secret" "store_pass" {
  name         = "vm-admin-password"
  value        = random_password.vm_password.result
  key_vault_id = azurerm_key_vault.this.id
  depends_on   = [azurerm_role_assignment.tf_keyvault_auth]
}

resource "azurerm_role_assignment" "tf_keyvault_auth" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

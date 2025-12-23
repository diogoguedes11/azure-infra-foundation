data "azurerm_client_config" "current" {}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "azurerm_key_vault" "this" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true

  sku_name                  = "standard"
  enable_rbac_authorization = true

  tags = var.common_tags
}

resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "vm-ssh-private-key"
  value        = tls_private_key.ssh.private_key_pem
  key_vault_id = azurerm_key_vault.this.id
  depends_on = [
    azurerm_role_assignment.main
  ]
}

resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "vm-ssh-public-key"
  value        = tls_private_key.ssh.public_key_openssh
  key_vault_id = azurerm_key_vault.this.id
  depends_on = [
    azurerm_role_assignment.main
  ]
}

resource "azurerm_role_assignment" "main" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_private_dns_zone" "vault_dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "vnet-link-to-keyvault-dns"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.vault_dns.name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false

}


resource "azurerm_private_endpoint" "kv_pe" {
  name                = "pe-keyvault"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-kv"
    private_connection_resource_id = azurerm_key_vault.this.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}

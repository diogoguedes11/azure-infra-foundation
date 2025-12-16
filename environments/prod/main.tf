
module "security" {
  source              = "../../modules/security"
  key_vault_name      = "kv-prod-foundation"
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id
}

module "storage" {
  source               = "../../modules/storage"
  storage_account_name = "stprodfoundation01"
  resource_group_name  = var.resource_group_name
  location             = var.location
  tenant_id            = var.tenant_id
}

module "networking" {
  source              = "../../modules/networking"
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
  vnet_name           = "vnet-foundation"
  location            = var.location
}

module "compute" {
  source                       = "../../modules/compute"
  prefix                       = "prodvm"
  location                     = "westeurope"
  resource_group_name          = module.networking.resource_group_name
  subnet_address_prefixes      = ["10.0.4.0/24"]
  vm_size                      = "Standard_B2s"
  virtual_network_name         = module.networking.vnet_name
  create_public_ip             = true
  admin_password               = module.security.vm_admin_password
  boot_diagnostics_storage_uri = module.storage.primary_blob_endpoint
}


resource "azurerm_role_assignment" "vm_key_vault_access" {
  principal_id         = module.compute.vm_principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = module.security.key_vault_id
}

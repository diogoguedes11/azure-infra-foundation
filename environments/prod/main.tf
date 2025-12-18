# Resource group
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

module "monitoring" {
  source              = "../../modules/monitoring"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
}

module "security" {
  source              = "../../modules/security"
  key_vault_name      = "kv-prod-foundation1105"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  tenant_id           = var.tenant_id
}

module "networking" {
  source              = "../../modules/networking"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
  vnet_name           = "vnet-foundation"
  location            = var.location
}

module "compute" {
  source                  = "../../modules/compute"
  prefix                  = "prodvm"
  location                = "westeurope"
  resource_group_name     = azurerm_resource_group.this.name
  subnet_address_prefixes = ["10.0.4.0/24"]
  vm_size                 = "Standard_B2s"
  virtual_network_name    = module.networking.vnet_name
  create_public_ip        = true
  admin_password          = module.security.vm_admin_password
}



resource "azurerm_role_assignment" "vm_key_vault_access" {
  principal_id         = module.compute.vm_principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = module.security.key_vault_id
}

# module "backups" {
#   source              = "../../modules/backups"
#   resource_group_name = azurerm_resource_group.this.name
#   location            = var.location
#   vm_id               = module.compute.vm_id
# }

resource "azurerm_monitor_data_collection_rule_association" "this" {
  name                    = "vm-dcr-assoc"
  target_resource_id      = module.compute.vm_id
  data_collection_rule_id = module.monitoring.dcr_id_output

}

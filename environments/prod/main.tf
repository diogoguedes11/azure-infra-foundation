locals {
  common_tags = {
    Project     = "Foundation"
    Environment = "prod"
    CostCenter  = "IT-Cloud-001"
    ManagedBy   = "Terraform"
  }
}
# Resource group
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# module "monitoring" {
#   source              = "../../modules/monitoring"
#   resource_group_name = azurerm_resource_group.this.name
#   location            = var.location
#   alert_email         = var.alert_email
# }

# Azure policies via governance module
module "governance" {
  source = "../../modules/governance"
}

resource "random_id" "name" {
  byte_length = 4
}
module "security" {
  source              = "../../modules/security"
  key_vault_name      = "kv-prod-foundation${random_id.name.id}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  tenant_id           = var.tenant_id
  common_tags         = local.common_tags
  virtual_network_id  = module.networking.vnet_id
  subnet_id           = module.networking.subnet_ids["snet-security"]
}

module "networking" {
  source              = "../../modules/networking"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
  vnet_name           = "vnet-foundation"
  location            = var.location
  common_tags         = local.common_tags
}

module "bastion" {
  source              = "../../modules/bastion"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  virtual_network_id  = module.networking.vnet_id
  common_tags         = local.common_tags
  subnet_id           = module.networking.subnet_ids["AzureBastionSubnet"]
}

module "compute" {
  source                  = "../../modules/compute"
  prefix                  = "prodvm"
  location                = var.location
  resource_group_name     = azurerm_resource_group.this.name
  subnet_address_prefixes = ["10.0.4.0/24"]
  vm_size                 = "Standard_B2s"
  virtual_network_name    = module.networking.vnet_name
  create_public_ip        = true
  subnet_id               = module.networking.subnet_ids["snet-backend"]
  ssh_public_key          = module.security.ssh_public_key
  common_tags             = local.common_tags
  vm_scale_set            = true # Set to true to deploy a VM Scale Set with LB
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

# resource "azurerm_monitor_data_collection_rule_association" "this" {
#   name                    = "vm-dcr-assoc"
#   target_resource_id      = module.compute.vm_id
#   data_collection_rule_id = module.monitoring.dcr_id_output

# }

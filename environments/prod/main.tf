
module "networking" {
  source              = "../../modules/networking"
  resource_group_name = "rg-foundation-prod"
  address_space       = ["10.0.0.0/16"]
  vnet_name           = "vnet-foundation"
  location            = "westeurope"
}

module "compute" {
  source                  = "../../modules/compute"
  prefix                  = "prodvm"
  location                = "westeurope"
  resource_group_name     = module.networking.resource_group_name
  subnet_address_prefixes = ["10.0.4.0/24"]
  vm_size                 = "Standard_B2s"
  virtual_network_name    = module.networking.vnet_name
  create_public_ip        = true
}

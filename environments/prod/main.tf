
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
  subnet_address_prefixes = module.networking.subnets["internal"]
  vm_size                 = "Standard_DS1_v2"
}

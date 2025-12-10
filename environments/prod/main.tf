
module "networking" {
  source              = "../../modules/networking"
  resource_group_name = "rg-foundation-prod"
  address_space       = ["10.0.0.0/16"]
  vnet_name           = "vnet-foundation"
  location            = "westeurope"
}

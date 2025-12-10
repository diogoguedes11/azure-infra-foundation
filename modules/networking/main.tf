
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}


resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  tags = {
    Environment = "Foundation"
    ManagedBy   = "Terraform"
  }
}


resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]
}
# NSG (Network Security Group)
resource "azurerm_network_security_group" "basic_nsg" {
  name                = "nsg-${var.vnet_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

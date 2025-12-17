# Virtual network
resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Owner       = "diogo.guedes"
  }
}

# Azure subnet
resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]
}

# NSG (Network Security Group)
resource "azurerm_network_security_group" "this" {
  name                = "nsg-${var.vnet_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Owner       = "diogo.guedes"
  }
}

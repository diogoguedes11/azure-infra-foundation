# Virtual network
resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  tags = var.common_tags
}

# Azure subnet
resource "azurerm_subnet" "internal" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]
}

# NSG (Network Security Group)
resource "azurerm_network_security_group" "main" {
  name                = "nsg-${var.vnet_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

resource "azurerm_network_security_rule" "allow_https_inbound" {
  name                        = "Allow-HTTPS-Inbound"
  priority                    = 110 # Updated priority to avoid conflict
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.main.name
  resource_group_name         = var.resource_group_name
}

resource "azurerm_network_security_rule" "allow_https_outbound" {
  name                        = "Allow-HTTPS-Outbound"
  priority                    = 101
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.main.name
  resource_group_name         = var.resource_group_name
}

resource "azurerm_resource_group" "this" {
  name     = "rg-hub-and-spoke"
  location = "East US"
}

resource "azurerm_subnet" "hub_subnet" {
  name                 = "hub-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vnet_hub.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "spoke_subnet" {
  name                 = "spoke-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vnet_spoke.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_virtual_network" "vnet_hub" {
  name                = "vnet-hub"
  location            = azurerm_resource_group.this.location
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.this.name

}

resource "azurerm_virtual_network" "vnet_spoke" {
  name                = "vnet-spoke"
  location            = azurerm_resource_group.this.location
  address_space       = ["10.1.0.0/16"]
  resource_group_name = azurerm_resource_group.this.name

}


resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-spoke"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.vnet_hub.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_spoke.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
  use_remote_gateways       = false
}

resource "azurerm_network_interface" "nic_spoke" {
  name                = "nic-spoke"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_virtual_machine" "vm_spoke" {
  name                  = "vm-spoke"
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  network_interface_ids = [azurerm_network_interface.nic_spoke.id]
  vm_size               = "Standard_B2s"

  storage_os_disk {
    name              = "osdisk-spoke"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "vmspoke"
    admin_username = "azureuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

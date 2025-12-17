resource "azurerm_subnet" "internal_subnet" {
  name                 = "internal"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.subnet_address_prefixes
}

resource "azurerm_network_interface" "primary_nic" {
  name                = "${var.prefix}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.public_ip[0].id : null
  }
}

resource "azurerm_public_ip" "public_ip" {
  count               = var.create_public_ip ? 1 : 0
  name                = "${var.prefix}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_machine" "virtual_machine" {
  name                  = "${var.prefix}-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.primary_nic.id]
  vm_size               = var.vm_size

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  identity {
    type = "SystemAssigned"
  }
  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.prefix}-vm"
    admin_username = "admintest"
    admin_password = var.admin_password
    custom_data    = filebase64("${path.module}/cloud-init.sh")
  }
  boot_diagnostics {
    enabled     = true
    storage_uri = var.boot_diagnostics_storage_uri
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Owner       = "diogo.guedes"
  }
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${azurerm_virtual_machine.virtual_machine.name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "203.0.113.0/24"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "main" {
  count               = var.create_public_ip ? 1 : 0
  name                = "${var.prefix}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "main" {
  count = var.vm_scale_set ? 0 : 1

  name                = "${var.prefix}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary-ip-config"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.main[0].id : null
  }
}

resource "azurerm_network_security_group" "main" {
  count = var.vm_scale_set ? 1 : 0

  name                = "${var.prefix}-nsg"
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
    source_address_prefix      = "0.0.0.0/0" # tests
    destination_address_prefix = "*"
  }
  # RDP
  security_rule {
    name                       = "RDP"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"

  }

}

resource "azurerm_network_interface_security_group_association" "main" {
  count = var.vm_scale_set ? 0 : 1

  network_interface_id      = azurerm_network_interface.main[count.index].id
  network_security_group_id = azurerm_network_security_group.main[count.index].id
}

resource "azurerm_linux_virtual_machine" "this" {
  count = var.vm_scale_set ? 0 : 1

  name                = "${var.prefix}-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = "admintest"

  network_interface_ids = [azurerm_network_interface.main[count.index].id]

  disable_password_authentication = true

  custom_data = filebase64("${path.module}/cloud-init.sh")
  os_disk {
    name                 = "${var.prefix}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = "admintest"
    public_key = var.ssh_public_key
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  tags = var.common_tags
}

resource "azurerm_virtual_machine_extension" "ama" {
  count = var.vm_scale_set ? 0 : 1

  name                       = "AMA"
  virtual_machine_id         = azurerm_linux_virtual_machine.this[count.index].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.13"
  auto_upgrade_minor_version = true
}


# VM Scale Set

resource "azurerm_public_ip" "lb_pip" {

  count = var.vm_scale_set ? 1 : 0

  name                = "${var.prefix}-lb-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.common_tags
}

resource "azurerm_lb" "main" {
  count = var.vm_scale_set ? 1 : 0

  name                = "${var.prefix}-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = var.common_tags

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_pip[count.index].id
  }
}

resource "azurerm_lb_backend_address_pool" "bepool" {
  count = var.vm_scale_set ? 1 : 0

  loadbalancer_id = azurerm_lb.main[count.index].id
  name            = "MainBackendPool"
}

# Health check probe
resource "azurerm_lb_probe" "http" {
  count = var.vm_scale_set ? 1 : 0

  loadbalancer_id = azurerm_lb.main[count.index].id
  name            = "http-probe"
  port            = 80
  protocol        = "Tcp"
}

resource "azurerm_lb_rule" "http" {
  count = var.vm_scale_set ? 1 : 0

  loadbalancer_id                = azurerm_lb.main[count.index].id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bepool[count.index].id]
  probe_id                       = azurerm_lb_probe.http[count.index].id
}


resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  count = var.vm_scale_set ? 1 : 0

  name                = "${var.prefix}-vmss"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.vm_size
  instances           = 2
  admin_username      = "admintest"
  admin_password      = "P4ssword1234"


  admin_ssh_key {
    username   = "admintest"
    public_key = var.ssh_public_key
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  network_interface {
    name                      = "vmss-nic"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.main[0].id
    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id

      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bepool[count.index].id]
    }
  }
  upgrade_mode = "Automatic"
  custom_data  = filebase64("${path.module}/cloud-init.sh")

  identity {
    type = "SystemAssigned"
  }

  tags = var.common_tags
  lifecycle {
    ignore_changes = [instances]
  }
}


resource "azurerm_monitor_autoscale_setting" "main" {

  count = var.vm_scale_set ? 1 : 0

  name                = "autoscale-config"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss[count.index].id

  profile {
    name = "defaultProfile"

    capacity {
      default = 2
      minimum = 2
      maximum = 5
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss[count.index].id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss[count.index].id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}

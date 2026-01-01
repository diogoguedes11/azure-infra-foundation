
resource "azurerm_bastion_host" "this" {
  name                = "bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
  sku                 = "Developer"
  virtual_network_id  = var.virtual_network_name

}

provider "azurerm" {
  version = "~> 2.6.0"
  subscription_id = var.subscription_id
  features {}
}

# Create resource group
resource "azurerm_resource_group" "rg" {
  name = "${var.resource_prefix}-rg"
  location = var.location
  tags = {
    environment = var.environment
  }
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name = "${var.resource_prefix}-vn"
  address_space = var.address_space
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name = "${var.resource_prefix}-sn"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix = var.address_prefix
}

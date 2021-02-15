provider "azurerm" {
  version = "~> 2.6.0"
  subscription_id = var.subscription_id
  features {}
}

# Create resource group
resource "azurerm_resource_group" "rg" {
  name = "rg-terraform"
  location = var.location
  tags = {
    environment = var.environment
    team = "devOps"
  }
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name = "vn-terraform"
  address_space = var.address_space
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

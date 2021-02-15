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

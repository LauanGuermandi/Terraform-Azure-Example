provider "azurerm" {
  version         = "~> 2.6.0"
  subscription_id = var.subscription_id
  features {}
}

# Create resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_prefix}-rg"
  location = var.location

  tags     = {
    environment = var.environment
  }
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_prefix}-vnet"
  address_space       = var.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.resource_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.address_prefix
}

# Create public ip
resource "azurerm_public_ip" "publicip" {
  name                = "${var.resource_prefix}-publicip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create network security group
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.resource_prefix}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create netowork security rule
resource "azurerm_network_security_rule" "nsr" {
  name                        = "${var.resource_prefix}-nsr"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Create netowork interface
resource "azurerm_network_interface" "nic" {
  name                        = "${var.resource_prefix}-nic"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create linux virtual machine
resource "azurerm_virtual_machine" "virtualmachine" {
  name                  = "${var.resource_prefix}-virtualmachine"
  vm_size               = var.vm_sku
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name

  network_interface_ids = [ 
    azurerm_network_interface.nic.id
  ]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.resource_prefix}-storage"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = var.vm_username
    admin_password = var.vm_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = var.environment
  }
}


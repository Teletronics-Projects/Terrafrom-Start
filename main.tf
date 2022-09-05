terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}




provider "azurerm" {
  features {}

  client_id       = "d9684a70-f1cb-4323-b410-5aa1bf0f76c8"
  subscription_id = "620830f5-7bad-46de-b40b-e54b75b8bb6b"
  tenant_id       = "7642f368-2fe4-497a-842a-2af1fdb63b98"
  client_secret   = "TKz8Q~G4ZeOoMIiv48cJZel2ojz.8pOC~yALRbXm"
}

resource "azurerm_resource_group" "TFA" {
  name     = var.resource_group_name
  location = var.resource_group_location
}


resource "azurerm_virtual_network" "vm1-vnet" {
  name                = "vm1-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.TFA.location
  resource_group_name = azurerm_resource_group.TFA.name
}

resource "azurerm_subnet" "vm-1-subnet1" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.TFA.name
  virtual_network_name = azurerm_virtual_network.vm1-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "vm1-nic1" {
  name                = "vm1-nic1"
  location            = azurerm_resource_group.TFA.location
  resource_group_name = azurerm_resource_group.TFA.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm-1-subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm-1" {
  name                = "FT-vm1"
  resource_group_name = var.resource_group_name
  location            = azurerm_resource_group.TFA.location
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = "TeleLogin@2020"
  network_interface_ids = [
    azurerm_network_interface.vm1-nic1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

terraform {
    required_providers {
        azurerm = {
            source  = "registry.terraform.io/hashicorp/azurerm"
            version = "~> 3.0.2"
        }
    }
    # Required version of terraform:
    required_version = ">= 1.1.0"
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "main" {
    name     = "${var.prefix}-resource-group"
    location = var.location
}

resource "azurerm_virtual_network" "vnet1" {
    resource_group_name = azurerm_resource_group.main.name
    name                = "${var.prefix}-virtual-network"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
}

resource "azurerm_subnet" "subnet1" {
    name                 = "subnet1"
    resource_group_name  = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.vnet1.name
    address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip" {
    name                = "${var.prefix}-pip"
    domain_name_label   = "${var.prefix}-pa11y-dashboard"
    resource_group_name = azurerm_resource_group.main.name
    location            = var.location
    allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
    name                = "${var.prefix}-nic1"
    resource_group_name = azurerm_resource_group.main.name
    location            = var.location
    
    ip_configuration {
        name                          = "primary"
        subnet_id                     = azurerm_subnet.subnet1.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.pip.id
    }
}

resource "azurerm_network_security_group" "nsg1" {
    name                = "network_security_group_1"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    
    security_rule {
        name                       = "ssh_access"
        access                     = "Allow"
        direction                  = "Inbound"
        protocol                   = "Tcp"
        priority                   = 100
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "http_access"
        access                     = "Allow"
        direction                  = "Inbound"
        protocol                   = "Tcp"
        priority                   = 200
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    # We may need a security rule to allow inbound HTTPS traffic on port 443.
}

resource "azurerm_subnet_network_security_group_association" "nsg_for_subnet1" {
    network_security_group_id = azurerm_network_security_group.nsg1.id
    subnet_id                 = azurerm_subnet.subnet1.id
}

resource "azurerm_linux_virtual_machine" "main" {
    name                            = "${var.prefix}-vm"
    location                        = var.location     
    resource_group_name             = azurerm_resource_group.main.name
    network_interface_ids           = [azurerm_network_interface.main.id]

    # Virtual machine size must be compatible with kernel image to be used.
    # v2 VMs in azure use a hypervisor (program that does the virtualizing) 
    # version that may not be compatible with some older versions of the 
    # linux kernel.
    size                            = "Standard_DS1_v2"

    computer_name                   = "jzd"
    admin_username                  = "adminuser"
    disable_password_authentication = true 
    provision_vm_agent              = true

    custom_data                     = base64encode ("${file(var.user_data)}")
    # A copy of this file can be referenced at this location on the new VM:
    # /var/lib/cloud/instances/<unique-instance-identifier>/user-data.txt

    source_image_reference {
        publisher = "Canonical"
        # Offer and sku names are non-standard for latest LTS Ubuntu Server.
        # Use Azure CLI to list images: az vm image list --publisher Canonical
        offer     = "0001-com-ubuntu-server-focal"
        sku       = "20_04-lts-gen2" 
        version   = "latest"
    }

    os_disk {
        storage_account_type = "Standard_LRS"
        caching              = "ReadWrite"
    }

    admin_ssh_key {
        username = "adminuser"
        public_key = file("${var.public_key_file_name}")
    }
}


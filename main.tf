terraform {
    required_providers {
        azurerm = {
            source  = "registry.terraform.io/hashicorp/azurerm"
            version = "~> 3.0.2"
        }
    }
    # Required version of terraform itself:
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
    domain_name_label   = "jzd-pa11y-dashboard"
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

# resource "azurerm_network_interface" "internal" {
#     name                = "${var.prefix}-nic2"
#     resource_group_name = azurerm_resource_group.main.name
#     location            = var.location
# 
#     ip_configuration {
#         name                          = "internal"
#         subnet_id                     = azurerm_subnet.subnet1.id
#         private_ip_address_allocation = "Dynamic"
#     }
# }

resource "azurerm_network_security_group" "nsg1" {
    name                = "network_security_group_1"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    
    # security_rule {
    #     access                     = "Allow"
    #     direction                  = "Inbound"
    #     name                       = "tls"
    #     priority                   = 100
    #     protocol                   = "Tcp"
    #     source_port_range          = "*"
    #     source_address_prefix      = "*"
    #     destination_port_range     = "443"
    #     destination_address_prefix = azurerm_network_interface.main.private_ip_address
    # }
    
    security_rule {
        name                       = "Egress"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "Inbound HTTP access"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_ranges          = ["22","80","443","3389"]
        destination_port_ranges     = ["22","80","443","3389"]
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        description                = "RDP-HTTP-HTTPS ingress traffic" 
    }
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
    size                            = "Standard_F2"
    computer_name                   = "jzd"
    #   admin_username                  = "adminuser"
    #   admin_password                  = "ILom4j72LAw773JGQrng"
    disable_password_authentication = true #false
    provision_vm_agent              = true
    custom_data                     = base64encode ("${file(var.user_data)}")

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }

    os_disk {
        storage_account_type = "Standard_LRS"
        caching              = "ReadWrite"
    }

    admin_ss_key {
        username = "adminuser"
        public_key = file("${var.public_key_file_name.pub}")
    }
}
       


# Configure the Microsoft Azure Provider
provider "azurerm" {
    
    features {}
}

variable "n" {
    type = number
    description = "No. of Worker Node"
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myk8sgroup" {
    name     = "k8sResourceGroup"
    location = "Central India"

    tags = {
        environment = "K8s Resource Group"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myk8snetwork" {
    name                = "k8sVnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.myk8sgroup.location
    resource_group_name = azurerm_resource_group.myk8sgroup.name

    tags = {
        environment = "K8s VN"
    }
}

# Create subnet
resource "azurerm_subnet" "myk8ssubnet" {
    name                 = "k8sSubnet"
    resource_group_name  = azurerm_resource_group.myk8sgroup.name
    virtual_network_name = azurerm_virtual_network.myk8snetwork.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myk8spublicip" {
    count                        = var.n
    name                         = "k8sPublicIP${count.index}"
    location                     = azurerm_resource_group.myk8sgroup.location
    resource_group_name          = azurerm_resource_group.myk8sgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "K8s Public IP"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myk8snsg" {
    name                = "k8sNetworkSecurityGroup"
    location            = azurerm_resource_group.myk8sgroup.location
    resource_group_name = azurerm_resource_group.myk8sgroup.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "K8s Security Group"
    }
}

# Create network interface
resource "azurerm_network_interface" "myk8snic" {
    count                     = var.n
    name                      = "k8sNIC${count.index}"
    location                  = azurerm_resource_group.myk8sgroup.location
    resource_group_name       = azurerm_resource_group.myk8sgroup.name

    ip_configuration {
        name                          = "myNicConfiguration${count.index}"
        subnet_id                     = azurerm_subnet.myk8ssubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.myk8spublicip.*.id, count.index)}"
    }

    tags = {
        environment = "K8s NIC"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "myk8ssga" {
    count                     = 2
    network_interface_id      = "${element(azurerm_network_interface.myk8snic.*.id, count.index)}"
    network_security_group_id = azurerm_network_security_group.myk8snsg.id
}


# Create virtual machine
resource "azurerm_linux_virtual_machine" "myk8svm" {
    count                 = var.n
    name                  = "k8sVM${count.index}"
    location              = azurerm_resource_group.myk8sgroup.location
    resource_group_name   = azurerm_resource_group.myk8sgroup.name
    network_interface_ids  = ["${element(azurerm_network_interface.myk8snic.*.id, count.index)}"]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk${count.index}"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
       publisher = "RedHat"
       offer     = "RHEL"
       sku       = "8.2"
       version   = "latest"
    }

    computer_name  = "WorkerNode${count.index}"
    admin_username = "ansible"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "ansible"
        public_key     = tls_private_key.k8s_ssh.public_key_openssh
    }

    tags = {
        environment = "Worker_Node"
    }
}



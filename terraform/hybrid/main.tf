terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    esxi = {
      source  = "josenk/esxi"
      version = "~> 1.10"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

resource "tls_private_key" "testuser" {
  algorithm = "ED25519"
}

resource "local_sensitive_file" "testuser_private_key" {
  filename        = "${path.module}/generated/testuser_id_ed25519"
  content         = tls_private_key.testuser.private_key_openssh
  file_permission = "0600"
}

resource "local_file" "testuser_public_key" {
  filename        = "${path.module}/generated/testuser_id_ed25519.pub"
  content         = tls_private_key.testuser.public_key_openssh
  file_permission = "0644"
}

data "azurerm_resource_group" "hybrid" {
  name = var.azure_resource_group_name
}

resource "azurerm_virtual_network" "hybrid" {
  name                = "${var.project_name}-vnet"
  address_space       = [var.azure_vnet_cidr]
  location            = data.azurerm_resource_group.hybrid.location
  resource_group_name = data.azurerm_resource_group.hybrid.name
}

resource "azurerm_subnet" "hybrid" {
  name                 = "${var.project_name}-subnet"
  resource_group_name  = data.azurerm_resource_group.hybrid.name
  virtual_network_name = azurerm_virtual_network.hybrid.name
  address_prefixes     = [var.azure_subnet_cidr]
}

resource "azurerm_network_security_group" "hybrid" {
  name                = "${var.project_name}-nsg"
  location            = data.azurerm_resource_group.hybrid.location
  resource_group_name = data.azurerm_resource_group.hybrid.name
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "allow-ssh"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.allowed_source_address_prefix
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.hybrid.name
  network_security_group_name = azurerm_network_security_group.hybrid.name
}

resource "azurerm_network_security_rule" "http" {
  name                        = "allow-http"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = var.allowed_source_address_prefix
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.hybrid.name
  network_security_group_name = azurerm_network_security_group.hybrid.name
}

resource "azurerm_public_ip" "hybrid" {
  name                = "${var.azure_vm_name}-pip"
  location            = data.azurerm_resource_group.hybrid.location
  resource_group_name = data.azurerm_resource_group.hybrid.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "hybrid" {
  name                = "${var.azure_vm_name}-nic"
  location            = data.azurerm_resource_group.hybrid.location
  resource_group_name = data.azurerm_resource_group.hybrid.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hybrid.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.hybrid.id
  }
}

resource "azurerm_network_interface_security_group_association" "hybrid" {
  network_interface_id      = azurerm_network_interface.hybrid.id
  network_security_group_id = azurerm_network_security_group.hybrid.id
}

resource "azurerm_linux_virtual_machine" "hybrid" {
  name                = var.azure_vm_name
  resource_group_name = data.azurerm_resource_group.hybrid.name
  location            = data.azurerm_resource_group.hybrid.location
  size                = var.azure_vm_size
  admin_username      = var.ansible_user
  network_interface_ids = [
    azurerm_network_interface.hybrid.id
  ]

  disable_password_authentication = true
  custom_data = base64encode(templatefile("${path.module}/templates/cloud-init-user-data.tpl", {
    ansible_user   = var.ansible_user
    ssh_public_key = chomp(file(pathexpand(var.azure_ssh_public_key_path)))
  }))

  admin_ssh_key {
    username   = var.ansible_user
    public_key = chomp(file(pathexpand(var.azure_ssh_public_key_path)))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "esxi_guest" "hybrid" {
  guest_name = var.esxi_vm_name
  disk_store = var.esxi_disk_store
  guestos    = var.esxi_guestos

  memsize  = var.esxi_memsize
  numvcpus = var.esxi_numvcpus
  power    = "on"

  network_interfaces {
    virtual_network = var.esxi_virtual_network
    nic_type        = var.esxi_nic_type
  }

  guestinfo = {
    "userdata" = base64gzip(templatefile("${path.module}/templates/cloud-init-user-data.tpl", {
      ansible_user   = var.ansible_user
      ssh_public_key = chomp(file(pathexpand(var.esxi_ssh_public_key_path)))
    }))
    "userdata.encoding" = "gzip+base64"
  }
}

locals {
  azure_public_ip = azurerm_public_ip.hybrid.ip_address
  esxi_host_ip    = var.esxi_vm_ip != "" ? var.esxi_vm_ip : esxi_guest.hybrid.ip_address
}

resource "local_file" "terraform_inventory" {
  filename = "${path.module}/inventory.ini"
  content = templatefile("${path.module}/templates/inventory.tpl", {
    azure_vm_name             = var.azure_vm_name
    azure_public_ip           = local.azure_public_ip
    esxi_vm_name              = var.esxi_vm_name
    esxi_host_ip              = local.esxi_host_ip
    ansible_user              = var.ansible_user
    azure_ssh_private_key_path = var.azure_ssh_private_key_path
    esxi_ssh_private_key_path  = var.esxi_ssh_private_key_path
    testuser_private_key      = local_sensitive_file.testuser_private_key.filename
    testuser_public_key       = local_file.testuser_public_key.filename
    container_image           = var.container_image
    container_name            = var.container_name
  })
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../../ansible/inventory.ini"
  content  = local_file.terraform_inventory.content
}

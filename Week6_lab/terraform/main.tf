terraform {
}


provider "azurerm" {
features {}
}


resource "azurerm_resource_group" "rg" {
name = var.rg_name
location = var.location
}


resource "azurerm_virtual_network" "vnet" {
name = "${var.prefix}-vnet"
resource_group_name = azurerm_resource_group.rg.name
location = azurerm_resource_group.rg.location
address_space = ["10.1.0.0/16"]
}


resource "azurerm_subnet" "subnet" {
name = "${var.prefix}-subnet"
resource_group_name = azurerm_resource_group.rg.name
virtual_network_name = azurerm_virtual_network.vnet.name
address_prefixes = ["10.1.1.0/24"]
}


resource "azurerm_public_ip" "pip" {
name = "${var.prefix}-pip"
location = azurerm_resource_group.rg.location
resource_group_name = azurerm_resource_group.rg.name
allocation_method = "Dynamic"
}


resource "azurerm_network_interface" "nic" {
name = "${var.prefix}-nic"
location = azurerm_resource_group.rg.location
resource_group_name = azurerm_resource_group.rg.name


ip_configuration {
name = "internal"
subnet_id = azurerm_subnet.subnet.id
private_ip_address_allocation = "Dynamic"
public_ip_address_id = azurerm_public_ip.pip.id
}
}


resource "azurerm_linux_virtual_machine" "vm" {
name = "${var.prefix}-vm"
resource_group_name = azurerm_resource_group.rg.name
location = azurerm_resource_group.rg.location
size = var.vm_size
admin_username = var.admin_user
network_interface_ids = [azurerm_network_interface.nic.id]


admin_ssh_key {
username = var.admin_user
public_key = file(var.ssh_public_key_path)
}


os_disk {
caching = "ReadWrite"
storage_account_type = "Standard_LRS"
}


source_image_reference {
publisher = "Canonical"
offer = "UbuntuServer"
sku = "22_04-lts"
version = "latest"
}


# cloud-init file used to bootstrap the VM (install docker, add user, etc.)
custom_data = file("${path.module}/../cloudinit/vm-init.yaml")
}
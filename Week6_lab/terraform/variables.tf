variable "subscription_id" {
type = string
default = "c064671c-8f74-4fec-b088-b53c568245eb"
}


variable "rg_name" {
type = string
default = "S1200715"
}


variable "location" {
type = string
default = "Sweden Central"
}


variable "prefix" {
type = string
default = "hybridlab"
}


variable "vm_size" {
type = string
default = "Standard_B1s"
}


variable "admin_user" {
type = string
default = "student"
}


variable "ssh_public_key_path" {
type = string
default = "~/.ssh/skylab.pub"
}
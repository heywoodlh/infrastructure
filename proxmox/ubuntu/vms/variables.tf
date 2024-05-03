variable "vm_id" {
  type = number
}

variable "proxmox_node" {
  type = string
  default = "proxmox-oryx-pro"
}

variable "hostname" {
  type = string
}

variable "datastore_id" {
  type = string
}

variable "memory" {
  type = number
  default = 4096
}

variable "cores" {
  type = number
  default = 2
}

variable "mac_address" {
  type = string
}

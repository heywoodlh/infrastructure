# Create clone from template
resource "proxmox_virtual_environment_vm" "nixos_vm" {
  name        = "${var.hostname}"
  description = "Managed by Terraform"
  tags        = ["terraform", "nixos"]

  node_name = "${var.proxmox_node}"
  vm_id     = "${var.vm_id}"

  clone {
    datastore_id = "${var.datastore_id}"
    node_name    = "proxmox-oryx-pro"
    vm_id        = 8003
  }

  cpu {
    cores = var.cores
  }
  memory {
    dedicated = var.memory
  }
  network_device {
    mac_address = "${var.mac_address}"
  }
}

# Create clone from template
resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name        = "${var.hostname}"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]

  node_name = "${var.proxmox_node}"
  vm_id     = "${var.vm_id}"

  clone {
    datastore_id = "local"
    node_name    = "proxmox-nvidia"
    vm_id        = 8002
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

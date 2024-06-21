resource "proxmox_virtual_environment_vm" "nixos_template" {
  name        = "nixos-template"
  description = "Managed by Terraform"
  tags        = ["terraform", "nixos"]

  node_name = "proxmox-oryx-pro"
  vm_id     = 8003

  agent {
    enabled = true
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  cdrom {
    enabled = true
    file_id = proxmox_virtual_environment_download_file.nixos_iso.id
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    size         = 256
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

  memory {
    dedicated = 2048
  }

  bios = "ovmf"
  machine = "q35"

  vga {
    type = "qxl"
    memory = 32
  }

  template = true
}

resource "proxmox_virtual_environment_download_file" "nixos_iso" {
  content_type       = "iso"
  datastore_id       = "local"
  file_name          = "nixos-24.05-gnome-x86_64.iso"
  node_name          = "proxmox-oryx-pro"
  url                = "https://channels.nixos.org/nixos-24.05/latest-nixos-gnome-x86_64-linux.iso"
}

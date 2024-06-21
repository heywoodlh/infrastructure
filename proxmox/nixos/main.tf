resource "null_resource" "create_iso" {
  provisioner "local-exec" {
    command = "nix build -o /tmp/nixos-cloud-init.iso ../..#image.x86_64-linux"
  }
}

output "iso_path" {
  value = "/tmp/nixos-cloud-init.iso"
}

resource "proxmox_virtual_environment_vm" "nixos-cloud-init-template" {
  name        = "nixos-cloud-init-template"
  description = "Managed by Terraform"
  tags        = ["terraform", "nixos"]

  node_name = "proxmox-nvidia"
  vm_id     = 8003

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local"
    file_id      = "local:iso/nixos-cloud-init.iso"
    interface    = "scsi0"
    size         = 80
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(data.http.vm_pubkey.response_body)]
      username = "heywoodlh"
    }
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

data "http" "vm_pubkey" {
  url = "https://github.com/heywoodlh.keys"
}

resource "proxmox_virtual_environment_file" "nixos_cloudimg" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox-nvidia"

  source_file {
    path = "/tmp/nixos-cloud-init.iso"
  }
}

#resource "proxmox_virtual_environment_download_file" "ubuntu_noble_cloudimg" {
#  content_type = "iso"
#  datastore_id = "local"
#  node_name    = "proxmox-nvidia"
#  file_name = "noble-server-cloudimg-amd64.img"
#  url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
#}

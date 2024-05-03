resource "proxmox_virtual_environment_vm" "talos_linux_template" {
  depends_on  = [null_resource.download_talos]
  name        = "talos-linux-template"
  description = "Managed by Terraform"
  tags        = ["terraform", "kubernetes"]

  node_name = "proxmox-nvidia"
  vm_id     = 8001

  agent {
    enabled = false
  }

  bios = "ovmf"

  disk {
    datastore_id = "local"
    file_id      = "local:iso/talos-nocloud-amd64.iso"
    interface    = "scsi0"
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

    user_data_file_id = proxmox_virtual_environment_file.cloud_config_kubernetes.id
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

  cpu {
    cores = 2
    type = "host"
  }
  memory {
    dedicated = 4096
  }

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

resource "null_resource" "download_talos" {
  connection {
    type = "ssh"
    user = "heywoodlh"
    host = "proxmox-nvidia"
    agent = true
    timeout = "10s"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo curl -C - -Lq https://github.com/siderolabs/talos/releases/download/v1.7.1/nocloud-amd64.raw.xz -o /var/lib/vz/template/iso/talos-nocloud-amd64.raw.xz",
      "sudo bash -c 'unxz /var/lib/vz/template/iso/talos-nocloud-amd64.raw.xz --stdout > /var/lib/vz/template/iso/talos-nocloud-amd64.iso'"
    ]
  }
}

# Ensure that snippets are enabled: `pvesm set local --content images,rootdir,vztmpl,iso,snippets`
resource "proxmox_virtual_environment_file" "cloud_config_kubernetes" {
  content_type = "snippets"
  datastore_id = "local"
  node_name = "proxmox-nvidia"
  source_raw {
    file_name = "kubernetes.yml"
    data = <<EOF
#cloud-config
runcmd:
  - |
    echo "test" > /tmp/testing.txt
  - |
    echo "test2" >> /tmp/testing.txt
EOF
  }
}

resource "proxmox_virtual_environment_vm" "talos_0" {
  depends_on  = [proxmox_virtual_environment_vm.talos_linux_template]
  name        = "talos-0"
  description = "Managed by Terraform"
  tags        = ["terraform", "kubernetes"]

  node_name = "proxmox-nvidia"
  vm_id     = "105"

  disk {
    datastore_id = "local"
    interface    = "scsi0"
  }

  clone {
    datastore_id = "local"
    vm_id        = 8001
  }
}


resource "proxmox_virtual_environment_vm" "talos_1" {
  depends_on  = [proxmox_virtual_environment_vm.talos_linux_template]
  name        = "talos-1"
  description = "Managed by Terraform"
  tags        = ["terraform", "kubernetes"]

  node_name = "proxmox-nvidia"
  vm_id     = "106"

  disk {
    datastore_id = "local"
    interface    = "scsi0"
  }

  clone {
    datastore_id = "local"
    vm_id        = 8001
  }
}

resource "proxmox_virtual_environment_vm" "talos_2" {
  depends_on  = [proxmox_virtual_environment_vm.talos_linux_template]
  name        = "talos-2"
  description = "Managed by Terraform"
  tags        = ["terraform", "kubernetes"]

  node_name = "proxmox-nvidia"
  vm_id     = "107"

  disk {
    datastore_id = "local"
    interface    = "scsi0"
  }

  clone {
    datastore_id = "local"
    vm_id        = 8001
  }
}

resource "proxmox_virtual_environment_download_file" "talos_img" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox-nvidia"
  file_name = "talos-metal-amd64.iso"
  url = "https://factory.talos.dev/image/077514df2c1b6436460bc60faabc976687b16193b8a1290fda4366c69024fec2/v1.7.1/metal-amd64.iso"
}

resource "proxmox_virtual_environment_vm" "talos_linux_template" {
  name        = "talos-linux-template"
  description = "Managed by Terraform"
  tags        = ["terraform", "kubernetes"]

  node_name = "proxmox-nvidia"
  vm_id     = 8001

  agent {
    enabled = true
  }

  bios = "ovmf"

  efi_disk {
    datastore_id = "local-lvm"
    type         = "4m"
    file_format  = "raw"
  }

  disk {
    datastore_id = "local"
    file_id      = proxmox_virtual_environment_download_file.talos_img.id
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

resource "proxmox_virtual_environment_vm" "talos_controller" {
  depends_on  = [proxmox_virtual_environment_vm.talos_linux_template]
  name        = "talos-controller"
  description = "Managed by Terraform"
  tags        = ["terraform", "kubernetes"]

  node_name = "proxmox-nvidia"
  vm_id     = "105"

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    size         = 40
  }

  network_device {
    bridge = "vmbr0"
    mac_address = "BC:24:11:F0:C8:93"
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

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    size         = 40
  }

  network_device {
    bridge = "vmbr0"
    mac_address = "BC:24:11:F0:C8:94"
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

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    size         = 40
  }

  network_device {
    bridge = "vmbr0"
    mac_address = "BC:24:11:F0:C8:95"
  }

  clone {
    datastore_id = "local"
    vm_id        = 8001
  }
}

resource "proxmox_virtual_environment_vm" "talos_ceph" {
  depends_on  = [proxmox_virtual_environment_vm.talos_linux_template]
  name        = "talos-ceph"
  description = "Managed by Terraform"
  tags        = ["terraform", "kubernetes"]

  node_name = "proxmox-nvidia"
  vm_id     = "109"

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    size         = 40
  }

  network_device {
    bridge = "vmbr0"
    mac_address = "BC:24:11:F0:C8:96"
  }

  clone {
    datastore_id = "local"
    vm_id        = 8001
  }
}


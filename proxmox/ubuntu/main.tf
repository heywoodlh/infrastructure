resource "proxmox_virtual_environment_vm" "ubuntu_noble_template" {
  name        = "ubuntu-noble-template"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]

  node_name = "proxmox-nvidia"
  vm_id     = 8002

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_noble_cloudimg.id
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

    user_data_file_id = proxmox_virtual_environment_file.cloud_config_qemu_guest_agent.id
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

resource "proxmox_virtual_environment_download_file" "ubuntu_noble_cloudimg" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox-nvidia"
  file_name = "noble-server-cloudimg-amd64.img"
  url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_file" "cloud_config_qemu_guest_agent" {
  content_type = "snippets"
  datastore_id = "local"
  node_name = "proxmox-nvidia"
  source_raw {
    file_name = "ubuntu.yml"
    data = <<EOF
#cloud-config

packages:
  - unattended-upgrades
  - qemu-guest-agent
  - curl
  - git
  - sudo

users:
  - name: heywoodlh
    gecos: Spencer Heywood
    primary_group: heywoodlh
    groups: users, admin
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCYn+7oSNHXN3qqDDidw42Vv7fDS0iEpYqaa0wCXRPBlfWAnD81f6dxj/QPGfZtxpl9jvk7nAKpE7RVUvQiJzUC2VM3Bw/4ucT+xliEHo3oesMQQa1AT70VPTbP5PdU7oUpgQWLq39j9XHno2YPJ/WWtuOl/UTjY6IDokkAmNmvft/jqqkiwSkGMmw68qrLFEM7+rNwJV5cXKvvpB6Gqc7qnbJmk1TZ1MRGW5eLjP9ofDqiyoLbnTm7Dw3iHn40GgTcnv5CWGpa0vrKnnLEGrgRB7kR/pyvfsjapkHz0PDvuinQov+MgJfV8B8PHdPC94dsS0DEWJplxhYojtsYa1VZy5zTEMNWICz1QG1yKHN1JQtpbEreHG6DVYvqwnKvK/XN5yiEeiamhD2oKnSh36PexIR0h0AAPO29Ln+anqpRlqJ0nET2CNS04e0vpV4VDJrG6BnyGUQ6CCo7THSq97F4Ne0nY9fpYu5WTFTCh1tTm+nSey0fP/xk22oINl/41VTI/Vk5pNQuuhHUvQupJHw9cD74aKzRddwvgfuAQjPlEuxxsqgFTltTiPF6lZQNeoMIc1OMCRsnl1xNqIepnb7Q5O1CGq+BqtOWh3G4/SPQI5ZUIkOAZegsnPpGWYMrRd7s6LJn5LrBYaY6IvRxmpGOig3tjOUy3fqk7coyTeJXmQ==
runcmd:
  - |
    systemctl enable --now unattended-upgrades
  - - systemctl
    - enable
    - --now
    - qemu-guest-agent.service
  - su -c 'curl -L https://files.heywoodlh.io/scripts/linux.sh | bash -s -- server --ansible --home-manager' - heywoodlh
  - ['sh', '-c', "echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf && echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf && sudo sysctl -p /etc/sysctl.d/99-tailscale.conf" ]
  - ['tailscale', 'up', '--authkey=${var.ts_api_key}']
package_update: true

write_files:
  - owner: root:root
    path: /etc/cron.d/sync_linux
    content: 0 * * * * heywoodlh curl -L https://files.heywoodlh.io/scripts/linux.sh | bash -s -- server --ansible --home-manager
EOF
  }
}

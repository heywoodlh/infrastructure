terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.55.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://proxmox-nvidia:8006/"
  # because self-signed TLS certificate is in use
  insecure = true
  tmp_dir  = "/tmp"

  ssh {
    agent = true
    username = "heywoodlh"
  }
}

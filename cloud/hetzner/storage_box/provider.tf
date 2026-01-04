terraform {
  backend "kubernetes" {
    secret_suffix    = "github-heywoodlh-infrastructure-cloud-hetzner"
    config_path      = "~/.kube/config"
  }
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "2.1.2"
    }
  }
}

# Configure the Hetzner Provider
provider "hcloud" {
  token = var.hcloud_token
}

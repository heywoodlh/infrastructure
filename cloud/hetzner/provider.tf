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
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.16.2"
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
provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = "heywoodlh.github"
}

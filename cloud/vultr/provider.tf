terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.21.0"
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

# Configure the Vultr Provider
provider "vultr" {
  api_key     = var.vultr_api_key
  rate_limit  = 700
  retry_limit = 3
}

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = "heywoodlh.github"
}

provider "onepassword" {
  account = "ZBM4RJDFRBFMBIELF3I6KKZ5MY"
}

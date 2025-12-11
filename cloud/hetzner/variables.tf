variable "hostname" {
  type = string
}

variable "region" {
  type = string
  default = "hil" # Oregon: `hcloud location list`
}

variable "plan" {
  type = string
  default = "cpx11" # `hcloud server-type list`
}

variable "os" {
  type = string
  default = "ubuntu-24.04" # Ubuntu 24.04: `hcloud image list`
}

variable "firewall_group" {
  type = string
  default = "10283054"
}

variable "tailscale_api_key" {
  type        = string
  sensitive   = true
}

variable "hcloud_token" {
  type        = string
  sensitive   = true
}

variable "storage_box_password" {
  type        = string
  sensitive   = true
}

variable "install_nix" {
  type = bool
  default = true
}

variable "nix_store_size" {
  type = number
  default = 50 # At time of writing, 50GB SDD is $2.50/month
}

variable "home_manager_target" {
  type = string
  default = "server --ansible" # args for the setup script
}

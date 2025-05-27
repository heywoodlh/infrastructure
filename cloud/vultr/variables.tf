variable "hostname" {
  type = string
}

variable "region" {
  type = string
  default = "lax" # Los Angeles: `vultr region list`
}

variable "plan" {
  type = string
  default = "vc2-1c-1gb" # `vultr plans list`
}

variable "os" {
  type = string
  default = "2284" # Ubuntu 24.04: `vultr os list`
}

variable "firewall_group" {
  type = string
  default = "8ddfa621-dd62-42ba-afea-6ce1ae762708"
}

variable "tailscale_api_key" {
  type        = string
  sensitive   = true
}

variable "vultr_api_key" {
  type        = string
  sensitive   = true
}

variable "install_nix" {
  type = bool
  default = true
}

variable "nix_store_type" {
  type = string
  default = "storage_opt" # HDD
}

variable "nix_store_size" {
  type = number
  default = 50 # At time of writing, 50GB of HDD is $1.25
}

variable "home_dir_type" {
  type = string
  default = "storage_opt" # HDD
}

variable "home_dir_size" {
  type = number
  default = 50 # At time of writing, 50GB of HDD is $1.25
}

variable "setup_args" {
  type = string
  default = "server --ansible" # args for the setup script
}

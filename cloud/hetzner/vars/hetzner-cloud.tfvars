hostname            = "hetzner-cloud"
plan                = "cpx11" # $5/month, `hcloud server-type list`
install_nix         = true
os                  = "ubuntu-24.04" # Ubuntu 24.04
nix_store_size      = 50 # ~$2.50/month SSD
home_manager_target = "github:heywoodlh/nixos-configs#homeConfigurations.heywoodlh-server.activationPackage"

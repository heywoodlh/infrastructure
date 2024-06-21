This directory contains Terraform configuration for general-purpose Ubuntu VMs.

## Deploy Ubuntu template

```
tf init
tf plan
tf apply
```

## Deploy VMs

```
cd vms
tf init -var-file=./vars/nixos-dev.tfvars
```

After the VM is initially installed, run the NixOS setup:

```
nixos-rebuild switch --flake "github:heywoodlh/nixos-configs#nixos-dev"
```

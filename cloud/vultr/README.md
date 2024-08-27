This directory contains Terraform configuration for general-purpose Linux VMs.

## Deploy VPS-es

```
tf init
tf plan -var-file=./vars/ubuntu-dev.tfvars
tf apply -var-file=./vars/ubuntu-dev.tfvars
```

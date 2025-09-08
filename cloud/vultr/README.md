This directory contains Terraform configuration for general-purpose Linux VMs.

## Deploy VPS-es

```
tf init
tf plan -var-file=./vars/ubuntu.tfvars
tf apply -var-file=./vars/ubuntu.tfvars
```

## Note to self

Credentials are handled in `.env_vars` and the <./bin/tf> wrapper

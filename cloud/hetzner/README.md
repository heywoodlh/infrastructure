This directory contains Terraform configuration for general-purpose Linux VMs.

## Deploy VPS-es

```
tf init
tf plan -var-file=./vars/hetzner-cloud.tfvars
tf apply -var-file=./vars/hetzner-cloud.tfvars
```

## Note to self

Credentials are handled in `.env_vars` and the <./bin/tf> wrapper

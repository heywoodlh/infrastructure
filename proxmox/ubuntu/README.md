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
tf init -var-file=./vars/k8s-nfs.tfvars
```

After the VM is setup, run the following command:

```
sudo hostnamectl hostname <hostname>
```

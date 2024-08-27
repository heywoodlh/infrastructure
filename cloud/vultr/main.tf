resource "tailscale_tailnet_key" "my_instance_key" {
  reusable      = true
  ephemeral     = false
  preauthorized = true
  expiry        = 3600
  tags          = ["tag:server"]
  description   = "Terraform Tailnet Key for authing ${var.hostname}"
}

resource "vultr_instance" "my_instance" {
  plan             = "${var.plan}"
  region           = "${var.region}"
  os_id            = var.os
  hostname         = "${var.hostname}"
  enable_ipv6      = false
  backups          = "disabled"
  ddos_protection  = false
  activation_email = false
  ssh_key_ids      = [
    "366c98b0-9012-47c7-90ca-fd98d189f160",
    "49a81001-7388-4014-9674-7360948f1f8a"
  ]
}

resource "vultr_block_storage" "nix_store" {
  size_gb              = var.nix_store_size
  region               = "${var.region}"
  attached_to_instance = vultr_instance.my_instance.id
  label                = "${var.hostname}_nix_store"
  block_type           = "storage_opt"
}

data "onepassword_item" "ssh_key" {
  vault = "Personal"
  uuid = "rlt3q545cf5a4r4arhnb4h5qmi"
}

resource "null_resource" "provision" {
  depends_on = [
    vultr_block_storage.nix_store,
    vultr_instance.my_instance
  ]

  connection {
    type        = "ssh"
    user        = "root"
    agent       = false
    host        = vultr_instance.my_instance.main_ip
    private_key = "${data.onepassword_item.ssh_key.private_key}"
  }

  provisioner "file" {
    source      = "./scripts/format-drive.sh"
    destination = "/tmp/format-drive.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://tailscale.com/install.sh | sh",
      "tailscale up --authkey ${tailscale_tailnet_key.my_instance_key.key}",
      "bash /tmp/format-drive.sh ${vultr_block_storage.nix_store.mount_id} | tee -a /tmp/format-drive.log",
      "userdel --remove ubuntu &>/dev/null || true",
      "userdel --remove linuxuser &>/dev/null || true",
      "mkdir -p /etc/sudoers.d",
      "echo 'heywoodlh ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/heywoodlh",
      "useradd -m heywoodlh --shell /bin/bash",
      "passwd -l heywoodlh",
      "sudo -H -u heywoodlh bash -c 'curl -L https://files.heywoodlh.io/scripts/linux.sh | bash -s -- server --ansible | tee -a /tmp/ansible-output.log'"
    ]
  }
}

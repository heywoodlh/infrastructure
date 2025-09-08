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
  label            = "${var.hostname}"
  enable_ipv6      = false
  backups          = "disabled"
  ddos_protection  = false
  activation_email = false
  ssh_key_ids      = [
    "366c98b0-9012-47c7-90ca-fd98d189f160",
    "49a81001-7388-4014-9674-7360948f1f8a",
    "fbb5bcd4-286b-4f6c-a83a-6421ec5478c1", # terraform-cli
  ]
  firewall_group_id = "8ddfa621-dd62-42ba-afea-6ce1ae762708" # ssh-from-trusted-only
}

# Wait for the instance ssh service to be ready before proceeding
resource "null_resource" "ssh_ready" {
  depends_on = [
    vultr_instance.my_instance
  ]
  provisioner "local-exec" {
    command = "./scripts/check.sh ${vultr_instance.my_instance.main_ip} 22"
  }
}

# Pause for 30s to allow all servers to become unlocked
resource "time_sleep" "wait_30_seconds" {
  depends_on = [
    null_resource.ssh_ready
  ]

  create_duration = "30s"
  destroy_duration = "30s"
}

resource "vultr_block_storage" "home_dir" {
  depends_on = [
    vultr_instance.my_instance,
    time_sleep.wait_30_seconds
  ]

  size_gb              = var.home_dir_size
  region               = "${var.region}"
  attached_to_instance = vultr_instance.my_instance.id
  label                = "${var.hostname}_home_dir"
  block_type           = var.home_dir_type
}

# Pause again for 30s to allow all servers to become unlocked
resource "time_sleep" "wait_30_seconds_2" {
  depends_on = [
    vultr_block_storage.home_dir
  ]
  create_duration = "30s"
  destroy_duration = "30s"
}

resource "vultr_block_storage" "nix_store" {
  count                = var.install_nix == true ? 1 : 0

  depends_on = [
    vultr_instance.my_instance,
    vultr_block_storage.home_dir
  ]

  size_gb              = var.nix_store_size
  region               = "${var.region}"
  attached_to_instance = vultr_instance.my_instance.id
  label                = "${var.hostname}_nix_store"
  block_type           = var.nix_store_type
  live                 = true
}

data "onepassword_item" "ssh_key" {
  vault = "Automation"
  uuid  = "zgrri6zlhpwzfn6szzvdphiswi"
}

resource "null_resource" "home_setup" {
  depends_on = [
    vultr_instance.my_instance,
    vultr_block_storage.home_dir,
    null_resource.ssh_ready
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
      "bash /tmp/format-drive.sh ${vultr_block_storage.home_dir.mount_id} /home/heywoodlh | tee -a /var/log/format-home.log && sudo chown -R 1000 /home/heywoodlh"
    ]
  }
}

resource "null_resource" "init_provision" {
  depends_on = [
    vultr_instance.my_instance,
    null_resource.home_setup
  ]

  connection {
    type        = "ssh"
    user        = "root"
    agent       = false
    host        = vultr_instance.my_instance.main_ip
    private_key = "${data.onepassword_item.ssh_key.private_key}"
  }

  provisioner "file" {
    source      = "./scripts/copy-ssh-keys.sh"
    destination = "/tmp/copy-ssh-keys.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://tailscale.com/install.sh | sh",
      "tailscale up --authkey ${tailscale_tailnet_key.my_instance_key.key}",
      "userdel --remove ubuntu &>/dev/null || true",
      "userdel --remove linuxuser &>/dev/null || true",
      "mkdir -p /etc/sudoers.d",
      "echo 'heywoodlh ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/heywoodlh",
      "groupadd heywoodlh",
      "useradd -m heywoodlh --shell /bin/bash --uid 1000 --gid heywoodlh --home-dir /home/heywoodlh",
      "passwd -l heywoodlh",
      "usermod -p '*' heywoodlh", # passwordless login via SSH's 'UsePAM no' setting
      "mkdir -p /home/heywoodlh/.ssh; curl --silent -L https://github.com/heywoodlh.keys -o /home/heywoodlh/.ssh/authorized_keys",
      "chown -R heywoodlh:heywoodlh /home/heywoodlh/.ssh",
      "chmod 700 /home/heywoodlh/.ssh; chmod 600 /home/heywoodlh/.ssh/authorized_keys",
      "sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config", # PAM severely slows down SSH on Vultr for some reason
      "systemctl restart sshd.service &>/dev/null || systemctl restart ssh.service &>/dev/null || true",
      "bash /tmp/copy-ssh-keys.sh",
    ]
  }
}

resource "null_resource" "nix_store" {
  count = var.install_nix == true ? 1 : 0

  depends_on = [
    vultr_block_storage.nix_store,
    vultr_instance.my_instance,
    null_resource.init_provision,
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
      "bash /tmp/format-drive.sh ${vultr_block_storage.nix_store[0].mount_id} /nix | tee -a /var/log/format-nix.log"
    ]
  }
}

resource "null_resource" "nix_install" {
  count = var.install_nix == true ? 1 : 0

  depends_on = [
    vultr_block_storage.nix_store,
    vultr_instance.my_instance,
    null_resource.init_provision,
    null_resource.nix_store,
  ]

  connection {
    type        = "ssh"
    user        = "heywoodlh"
    agent       = false
    host        = vultr_instance.my_instance.main_ip
    private_key = "${data.onepassword_item.ssh_key.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm --determinate",
      "/nix/var/nix/profiles/default/bin/nix --extra-experimental-features 'nix-command flakes' run ${var.home_manager_target} --impure | tee -a /tmp/setup.log"
    ]
  }
}

resource "null_resource" "ansible_standalone_install" {
  count = var.install_nix == false ? 1 : 0

  depends_on = [
    vultr_instance.my_instance,
    null_resource.init_provision,
  ]

  connection {
    type        = "ssh"
    user        = "root"
    agent       = false
    host        = vultr_instance.my_instance.main_ip
    private_key = "${data.onepassword_item.ssh_key.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "curl --silent -L https://raw.githubusercontent.com/heywoodlh/flakes/refs/heads/main/ansible/server/files/scripts/install-ansible.sh | bash",
      "curl --silent -L https://raw.githubusercontent.com/heywoodlh/flakes/main/ansible/requirements.yml -o /tmp/requirements.yml",
      "/root/.local/bin/ansible-galaxy install -r /tmp/requirements.yml",
      "/root/.local/bin/ansible-pull -U https://github.com/heywoodlh/flakes ansible/server/standalone.yml -e ansible_python_interpreter=/usr/bin/python3",
    ]
  }
}

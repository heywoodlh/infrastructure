resource "tailscale_tailnet_key" "my_instance_key" {
  reusable      = true
  ephemeral     = false
  preauthorized = true
  expiry        = 3600
  tags          = ["tag:server"]
  description   = "Terraform Tailnet Key for authing ${var.hostname}"
}


resource "hcloud_server" "node1" {
  name          = "${var.hostname}"
  image         = "${var.os}"
  server_type   = "${var.plan}"
  location      = "${var.region}"
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
  ssh_keys = [
    "104438280"
  ]
  firewall_ids = [
    "10283054"
  ]
}

resource "hcloud_volume" "nix_store" {
  count     = var.install_nix == true ? 1 : 0

  depends_on = [
    hcloud_server.node1
  ]

  name      = "${var.hostname}-nix"
  size      = var.nix_store_size
  server_id = hcloud_server.node1.id
  automount = false
  format    = "ext4"
}

# Wait for the instance ssh service to be ready before proceeding
resource "null_resource" "ssh_ready" {
  depends_on = [
    hcloud_server.node1
  ]
  provisioner "local-exec" {
    command = "./scripts/check.sh ${hcloud_server.node1.ipv4_address} 22"
  }
}

# Pause for 30s
resource "time_sleep" "wait_30_seconds" {
  depends_on = [
    null_resource.ssh_ready
  ]

  create_duration = "30s"
  destroy_duration = "30s"
}

data "onepassword_item" "ssh_key" {
  vault = "Automation"
  uuid  = "zgrri6zlhpwzfn6szzvdphiswi"
}

resource "null_resource" "init_provision" {
  depends_on = [
    hcloud_server.node1,
  ]

  connection {
    type        = "ssh"
    user        = "root"
    agent       = false
    host        = hcloud_server.node1.ipv4_address
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
      "mkdir -p /home/heywoodlh/.ssh; curl --silent -L https://github.com/heywoodlh.keys -o /home/heywoodlh/.ssh/authorized_keys",
      "chown -R heywoodlh:heywoodlh /home/heywoodlh/.ssh",
      "chmod 700 /home/heywoodlh/.ssh; chmod 600 /home/heywoodlh/.ssh/authorized_keys",
      "bash /tmp/copy-ssh-keys.sh",
    ]
  }
}

resource "null_resource" "nix_store" {
  count = var.install_nix == true ? 1 : 0

  depends_on = [
    hcloud_volume.nix_store,
    hcloud_server.node1,
    null_resource.init_provision,
  ]

  connection {
    type        = "ssh"
    user        = "root"
    agent       = false
    host        = hcloud_server.node1.ipv4_address
    private_key = "${data.onepassword_item.ssh_key.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /nix",
      "echo \"${hcloud_volume.nix_store[0].linux_device} /nix ext4 discard,defaults 0 0\" >> /etc/fstab",
      "mount -a",
    ]
  }
}

resource "null_resource" "nix_install" {
  count = var.install_nix == true ? 1 : 0

  depends_on = [
    hcloud_volume.nix_store,
    hcloud_server.node1,
    null_resource.init_provision,
    null_resource.nix_store,
  ]

  connection {
    type        = "ssh"
    user        = "heywoodlh"
    agent       = false
    host        = hcloud_server.node1.ipv4_address
    private_key = "${data.onepassword_item.ssh_key.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm --determinate",
      "/nix/var/nix/profiles/default/bin/nix --extra-experimental-features 'nix-command flakes' run ${var.home_manager_target} --impure | tee -a /tmp/setup.log",
      "apt update && apt install -y git python3-debian",
      "/nix/var/nix/profiles/default/bin/nix --extra-experimental-features 'nix-command flakes' run \"github:heywoodlh/nixos-configs/$(git ls-remote https://github.com/heywoodlh/nixos-configs | head -1 | awk '{print $1}')?dir=flakes/ansible#server\""
    ]
  }
}

resource "null_resource" "ansible_standalone_install" {
  count = var.install_nix == false ? 1 : 0
  depends_on = [
    hcloud_server.node1,
    null_resource.init_provision,
  ]

  connection {
    type        = "ssh"
    user        = "root"
    agent       = false
    host        = hcloud_server.node1.ipv4_address
    private_key = "${data.onepassword_item.ssh_key.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "curl --silent -L https://raw.githubusercontent.com/heywoodlh/nixos-configs/refs/heads/master/flakes/ansible/server/files/scripts/install-ansible.sh | bash",
      "curl --silent -L https://raw.githubusercontent.com/heywoodlh/nixos-configs/master/flakes/ansible/requirements.yml -o /tmp/requirements.yml",
      "/root/.local/bin/ansible-galaxy install -r /tmp/requirements.yml",
      "/root/.local/bin/ansible-pull -U https://github.com/heywoodlh/nixos-configs flakes/ansible/server/standalone.yml -e ansible_python_interpreter=/usr/bin/python3",
    ]
  }
}

resource "hcloud_storage_box" "cloud_data" {
  count = var.hostname == "hetzner-cloud" ? 1 : 0

  depends_on = [
    null_resource.nix_install,
  ]

  name             = "cloud_data"
  storage_box_type = "bx21"
  location         = "hel1"
  password         = var.storage_box_password

  access_settings = {
    reachable_externally = false
    samba_enabled        = true
    ssh_enabled          = true
    webdav_enabled       = true
    zfs_enabled          = true
  }

  snapshot_plan = {
    max_snapshots = 5
    minute        = 16
    hour          = 18
    day_of_week   = 3
  }

  delete_protection = true
}

resource "null_resource" "cloud_data_mount" {
  count = var.hostname == "hetzner-cloud" ? 1 : 0

  depends_on = [
    hcloud_storage_box.cloud_data,
  ]

  connection {
    type        = "ssh"
    user        = "heywoodlh"
    agent       = false
    host        = hcloud_server.node1.ipv4_address
    private_key = "${data.onepassword_item.ssh_key.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /data",
      "apt update && apt install -y cifs-utils",
      "echo \"username=${hcloud_storage_box.cloud_data[0].username}\" > /etc/backup-credentials.txt",
      "echo \"password=${var.storage_box_password}\" >> /etc/backup-credentials.txt",
      "echo \"//${hcloud_storage_box.cloud_data[0].server}/backup /data       cifs    iocharset=utf8,rw,seal,credentials=/etc/backup-credentials.txt,uid=1000,gid=1000,file_mode=0660,dir_mode=0750 0       0\" >> /etc/fstab",
      "mount -a",
    ]
  }
}


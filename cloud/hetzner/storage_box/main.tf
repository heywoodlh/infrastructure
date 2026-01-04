resource "hcloud_storage_box" "my_box" {
  name             = var.name
  storage_box_type = var.plan
  location         = var.region
  password         = var.storage_box_password

  access_settings = {
    reachable_externally = var.external
    samba_enabled        = false
    ssh_enabled          = true
    webdav_enabled       = false
    zfs_enabled          = true
  }

  snapshot_plan = {
    max_snapshots = 5
    minute        = 16
    hour          = 18
    day_of_week   = 3
  }

  ssh_keys = var.ssh_keys

  delete_protection = true
}

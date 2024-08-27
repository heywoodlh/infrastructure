#!/usr/bin/env bash

# matches volume name in /dev/disk/by-id
# i.e. /dev/disk/by-id/virtio-lax-7d3320e2371c4d
# should be ./format-drive.sh "lax-7d3320e2371c4d"
disk_id="$1"

[[ -z "${disk_id}" ]] && echo "Usage: $0 <disk-id>" && exit 1

disk_full_path="/dev/disk/by-id/virtio-${disk_id}"
disk_real_path="$(realpath ${disk_full_path})"

[[ -z "${disk_real_path}" ]] && echo "Unable to identify disk full path. Exiting." && exit 1

if ls -l "${disk_real_path}1" &>/dev/null
then
  echo 'Filesystem already formatted'
else
  echo "Formatting filesystem"
  parted -s "${disk_real_path}" mklabel gpt
  parted -s "${disk_real_path}" unit mib mkpart primary 0% 100%
  mkfs.ext4 "${disk_real_path}1"
fi

disk_fs_uuid="$(blkid -s UUID -o value ${disk_real_path}1)"

if grep -q "/nix" /etc/fstab
then
  echo "Filesystem for /nix already in fstab."
else
  echo "UUID=${disk_fs_uuid} /nix ext4 defaults,noatime,nofail 0 0" >> /etc/fstab
fi

mkdir -p /nix
mount -a
[[ -d /nix/lost+found ]] && rmdir /nix/lost+found

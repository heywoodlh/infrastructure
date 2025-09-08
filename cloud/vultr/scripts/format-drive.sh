#!/usr/bin/env bash

# matches volume name in /dev/disk/by-id
# i.e. /dev/disk/by-id/virtio-lax-7d3320e2371c4d
# should be ./format-drive.sh "lax-7d3320e2371c4d" "/nix"
disk_id="$1"
mount_point="$2"

[[ -z "${disk_id}" ]] && echo "Usage: $0 <disk-id>" && exit 1

echo "Using disk ID: ${disk_id}"
echo "Mount point: ${mount_point}"

disk_full_path="/dev/disk/by-id/virtio-${disk_id}"
disk_real_path="$(realpath ${disk_full_path})"

[[ -z "${disk_real_path}" ]] && echo "Unable to identify disk full path. Exiting." && exit 1

if ls -l "${disk_real_path}1" &>/dev/null
then
  echo 'Filesystem already formatted'
else
  echo "Formatting filesystem: ${disk_real_path}1 => ext4"
  parted -s "${disk_real_path}" mklabel gpt
  parted -s "${disk_real_path}" unit mib mkpart primary 0% 100%
  sleep 5 # encountered "The file /dev/sda1 does not exist and no size was specified" error without this
  mkfs.ext4 "${disk_real_path}1" || { echo "Failed to format disk. Exiting."; exit 1; }
fi

disk_fs_uuid="$(blkid -s UUID -o value ${disk_real_path}1)"
[[ -z "${disk_fs_uuid}" ]] && echo "Unable to retrieve disk UUID. Exiting." && exit 1

if grep -q "${mount_point}" /etc/fstab
then
  echo "Filesystem for ${mount_point} already in fstab."
else
  echo "UUID=${disk_fs_uuid} ${mount_point} ext4 defaults,noatime,nofail 0 0" >> /etc/fstab
fi

mkdir -p ${mount_point}
systemctl daemon-reload
mount -a
[[ -d ${mount_point}/lost+found ]] && rmdir ${mount_point}/lost+found

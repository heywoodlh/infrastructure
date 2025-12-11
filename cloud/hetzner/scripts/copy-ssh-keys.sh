#!/usr/bin/env bash
# This script copies SSH keys from root to heywoodlh
src="/root/.ssh/authorized_keys"
dest="/home/heywoodlh/.ssh/authorized_keys"

while IFS="" read -r key || [ -n "$key" ]
do
  if grep -q "${key}" "${dest}"
  then
    echo "Key already exists in authorized_keys, skipping: $key"
  else
    echo "Adding key to authorized_keys: $key"
    printf "%s\n" "${key}" >> "${dest}"
  fi
done < "${src}"

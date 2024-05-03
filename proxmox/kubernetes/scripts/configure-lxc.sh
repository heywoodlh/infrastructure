#!/usr/bin/env bash

conf_file=$1

[[ -z $conf_file ]] && echo "Usage: $0 <lxc-config-file>" && exit 1

lines=( "lxc.apparmor.profile: unconfined" "lxc.cgroup2.devices.allow: a" "lxc.cap.drop:" 'lxc.mount.auto: "proc:rw sys:rw' )

for line in "${lines[@]}"
do
    grep -q "$line" "${conf_file}" &>/dev/null || echo "${line}" | tee -a "${conf_file}"
done

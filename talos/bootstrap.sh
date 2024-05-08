#!/usr/bin/env bash
root_dir="$(dirname -- "$( readlink -f -- "$0"; )";)"
export TALOSCONFIG="${root_dir}/talosconfig"
CONTROL_PLANE_IP="192.168.50.40"
WORKER_IP_1="192.168.50.41"
WORKER_IP_2="192.168.50.42"
STORAGE_IP_1="192.168.50.43"

# Usage
if [ "$#" -ne 1 ]
then
  echo "Usage: $0 [controlplane|workers|storage]"
  exit 1
fi

# control plane
if [ "$1" == "controlplane" ]
then
  echo 'Bootstrapping control plane'
  talosctl bootstrap --talosconfig "${TALOSCONFIG}" -e "${CONTROL_PLANE_IP}" -n "${CONTROL_PLANE_IP}" || true
  echo 'Applying control plane'
  talosctl apply-config --talosconfig "${TALOSCONFIG}" --insecure --nodes "${CONTROL_PLANE_IP}" --file ./controlplane.yaml
fi

# workers
if [ "$1" == "workers" ]
then
  echo 'Applying workers'
  talosctl apply-config --talosconfig "${TALOSCONFIG}" --insecure --nodes "${WORKER_IP_1}" --file ./worker.yaml
  talosctl apply-config --talosconfig "${TALOSCONFIG}" --insecure --nodes "${WORKER_IP_2}" --file ./worker.yaml
fi

# storage
if [ "$1" == "storage" ]
then
  echo 'Applying storage'
  talosctl apply-config --talosconfig "${TALOSCONFIG}" --insecure --nodes "${STORAGE_IP_1}" --file ./storage.yaml
fi

#!/usr/bin/env bash
root_dir="$(dirname -- "$( readlink -f -- "$0"; )";)"
export TALOSCONFIG="${root_dir}/talosconfig"
CONTROL_PLANE_IP="192.168.50.40"
WORKER_IP_1="192.168.50.41"
WORKER_IP_2="192.168.50.42"
STORAGE_IP_1="192.168.50.43"

echo 'Applying control plane'
talosctl apply-config --talosconfig "${TALOSCONFIG}" --nodes "${CONTROL_PLANE_IP}" --file ./controlplane.yaml "$@"

echo 'Applying workers'
talosctl apply-config --talosconfig "${TALOSCONFIG}" --nodes "${WORKER_IP_1}" --file ./worker.yaml "$@"
talosctl apply-config --talosconfig "${TALOSCONFIG}" --nodes "${WORKER_IP_2}" --file ./worker.yaml "$@"

echo 'Applying storage'
talosctl apply-config --talosconfig "${TALOSCONFIG}" --nodes "${STORAGE_IP_1}" --file ./storage.yaml "$@"

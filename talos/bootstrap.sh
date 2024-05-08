#!/usr/bin/env bash
CONTROL_PLANE_IP="192.168.50.40"
WORKER_IP_1="192.168.50.41"
WORKER_IP_2="192.168.50.42"

# control plane
talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file ./controlplane.yaml

# workers
talosctl apply-config --insecure --nodes "$WORKER_IP_1,$WORKER_IP_2" --file ./worker.yaml

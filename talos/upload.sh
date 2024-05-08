#!/usr/bin/env bash

item="h6d3bdi7yx2kvrk64u2lolva74"

op item edit "${item}" "controlplane\.yaml=$(cat ./controlplane.yaml)"
op item edit "${item}" "talosconfig=$(cat ./talosconfig)"
op item edit "${item}" "worker\.yaml=$(cat ./worker.yaml)"

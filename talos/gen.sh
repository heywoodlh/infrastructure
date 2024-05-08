#!/usr/bin/env bash

item="op://kubernetes/h6d3bdi7yx2kvrk64u2lolva74"

op read "${item}/controlplane.yaml" > controlplane.yaml
op read "${item}/talosconfig" > talosconfig
op read "${item}/worker.yaml" > worker.yaml

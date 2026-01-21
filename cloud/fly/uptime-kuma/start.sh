#!/usr/bin/env bash
/tailscale/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
/tailscale/tailscale up --auth-key=${TAILSCALE_AUTHKEY} --hostname=uptime-kuma

/usr/bin/dumb-init -- node /app/server/server.js

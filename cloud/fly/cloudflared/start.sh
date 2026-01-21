#!/usr/bin/env ash
/tailscale/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
/tailscale/tailscale up --auth-key=${TAILSCALE_AUTHKEY} --hostname=fly-cloudflared

/usr/bin/cloudflared tunnel --no-autoupdate run --token ${CLOUDFLARE_TOKEN}

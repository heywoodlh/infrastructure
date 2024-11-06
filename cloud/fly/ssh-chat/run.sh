#!/usr/bin/env ash

# Start Tailscale
/app/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
/app/tailscale up --auth-key=${TS_AUTHKEY} --hostname=ssh-chat

# Start ssh-chat
[ -e /data/ssh/id_rsa ] || ssh-keygen -t rsa -C "chatkey" -f /data/ssh/id_rsa
/usr/local/bin/ssh-chat --bind "0.0.0.0:2222" --identity=/data/ssh/id_rsa --admin=/opt/admin_authorized_keys --motd=/opt/motd.txt --whitelist=/opt/authorized_keys

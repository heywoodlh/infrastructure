#!/usr/bin/env bash

tailscale_token="$1"

[[ -z "${tailscale_token}" ]] && echo "Usage: $0 TAILSCALE_API_KEY" && exit 1

apt update && apt install -y curl sudo

# Add heywoodlh user
adduser --disabled-password --gecos "" heywoodlh
echo "heywoodlh ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers
mkdir -p -m 700 /home/heywoodlh/.ssh
curl https://github.com/heywoodlh.keys -o /home/heywoodlh/.ssh/authorized_keys
chmod 600 /home/heywoodlh/.ssh/authorized_keys
chown -R heywoodlh /home/heywoodlh/.ssh

# Run installer
sudo -H -u heywoodlh bash -c 'curl -L https://files.heywoodlh.io/scripts/linux.sh | bash -s -- server --ansible --home-manager'

tailscale up --authkey "${tailscale_token}"

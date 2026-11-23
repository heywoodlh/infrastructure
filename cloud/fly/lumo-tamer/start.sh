#!/bin/sh
set -eu

DATA_DIR="/app/data"
VAULT_PATH="${DATA_DIR}/sessions/vault.enc"

# The container runs as root, so binding 80 is fine. Only used when
# config.yaml is first generated; change the volume's config.yaml afterwards.
LUMO_PORT="${LUMO_PORT:-80}"

if [ -z "${LUMO_API_KEY:-}" ]; then
  echo "FATAL: LUMO_API_KEY is not set (fly secrets set LUMO_API_KEY=...)" >&2
  exit 1
fi

if [ -z "${LUMO_VAULT_KEY:-}" ]; then
  echo "FATAL: LUMO_VAULT_KEY is not set (fly secrets set LUMO_VAULT_KEY=...)" >&2
  exit 1
fi

mkdir -p "${DATA_DIR}/sessions" "${DATA_DIR}/tailscale" /var/run/tailscale

# Vault key is supplied as a Fly secret so it stays identical across boots and
# auth sessions. lumo-tamer accepts a base64-encoded 32-byte key.
umask 077
printf '%s' "${LUMO_VAULT_KEY}" > "${DATA_DIR}/lumo-vault-key"

# lumo-tamer resolves config.yaml and sessions/ relative to its project root
# (/app), so point both at the persistent volume.
if [ ! -e /app/config.yaml ]; then
  ln -s "${DATA_DIR}/config.yaml" /app/config.yaml
fi
if [ ! -e /app/sessions ]; then
  ln -s "${DATA_DIR}/sessions" /app/sessions
fi

if [ ! -s "${DATA_DIR}/config.yaml" ]; then
  cat > "${DATA_DIR}/config.yaml" <<EOF
auth:
  method: "login"
  vault:
    path: "sessions/vault.enc"
    keyFilePath: "/app/data/lumo-vault-key"

server:
  apiKey: "${LUMO_API_KEY}"
  port: ${LUMO_PORT}
EOF
fi

/tailscale/tailscaled \
  --state="${DATA_DIR}/tailscale/tailscaled.state" \
  --socket=/var/run/tailscale/tailscaled.sock &

if [ -n "${TAILSCALE_AUTHKEY:-}" ]; then
  /tailscale/tailscale up \
    --auth-key="${TAILSCALE_AUTHKEY}" \
    --hostname=lumo \
    --timeout=60s ||
    echo "WARN: tailscale up failed; will keep using existing state if present" >&2
elif [ ! -f "${DATA_DIR}/tailscale/tailscaled.state" ]; then
  echo "WARN: TAILSCALE_AUTHKEY not set and no tailscale state exists" >&2
fi

if [ ! -s "${VAULT_PATH}" ]; then
  cat <<'MSG'
============================================================
lumo-tamer is not authenticated yet; the API server is paused.

Run "tamer auth login" (or "tamer auth rclone") in this machine:

  fly ssh console -a heywoodlh-lumo-tamer
  cd /app && tamer auth login

Then restart the machine:

  fly machine restart <machine-id> -a heywoodlh-lumo-tamer

See README.md for fallbacks when Proton returns a CAPTCHA.
============================================================
MSG
  while :; do sleep 3600; done
fi

exec tamer server

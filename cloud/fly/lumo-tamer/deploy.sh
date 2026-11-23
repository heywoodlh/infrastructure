#!/usr/bin/env bash
set -euo pipefail

APP="heywoodlh-lumo-tamer"
REGION="lax"
VOLUME="data"
OP_ITEM="qp43o4locdg7gq64nhl5apqcoe"
FORCE="${FORCE:-false}"

cd "$(dirname "$0")"

# The nixos-configs op-wrapper unlocks 1Password and exports OP_SESSION itself,
# so prefer it when it is on PATH (e.g. inside the infrastructure devShell).
# Fall back to the plain CLI, loading the session file that op-unlock writes.
if command -v op-wrapper >/dev/null 2>&1; then
  OP="op-wrapper"
else
  OP="op"
  if [ -f "${HOME}/.1password/session.sh" ]; then
    set -a
    . "${HOME}/.1password/session.sh"
    set +a
  fi
fi

op_read() {
  local field="$1" value
  value="$("$OP" item get "$OP_ITEM" --reveal --fields "$field")" || {
    echo "ERROR: could not read '${field}' from 1Password; run op-unlock (or op signin) first" >&2
    return 1
  }
  if [ -z "$value" ]; then
    echo "ERROR: '${field}' is empty in 1Password" >&2
    return 1
  fi
  printf '%s' "$value"
}

fly apps list | awk '{print $1}' | grep -qx "$APP" || fly apps create "$APP"

fly volumes list -a "$APP" | grep -qE "[[:space:]]${VOLUME}[[:space:]]" ||
  fly volumes create "$VOLUME" -r "$REGION" -s 1 -a "$APP"

if [ "$FORCE" = "true" ]; then
  TAILSCALE_AUTHKEY="$(op_read ts-authkey)"
  LUMO_API_KEY="$(op_read api-key)"
  LUMO_VAULT_KEY="$(op_read vault-key)"

  fly secrets set \
    TAILSCALE_AUTHKEY="$TAILSCALE_AUTHKEY" \
    LUMO_API_KEY="$LUMO_API_KEY" \
    LUMO_VAULT_KEY="$LUMO_VAULT_KEY" \
    -a "$APP"
fi

fly deploy --ha=false

Tailscale-enabled [lumo-tamer](https://github.com/ZeroTricks/lumo-tamer) deployment on fly.io, reachable only from the tailnet at `http://lumo.barn-banana.ts.net` (plaintext HTTP on port 80).

```
FORCE=true ./cloud/fly/lumo-tamer/deploy.sh
```

`FORCE=true` reads `TAILSCALE_AUTHKEY`, `LUMO_API_KEY` and `LUMO_VAULT_KEY` from 1Password; without it the script leaves existing secrets alone. Run `op-unlock` first (the script uses `op-wrapper` when available, otherwise it loads `~/.1password/session.sh`), and it aborts rather than staging empty secrets if 1Password is locked. The app and the `data` volume are created when missing and the deploy is limited to a single machine (`--ha=false`), so the script is safe to re-run.

lumo-tamer does not start without a Proton session, so the first boot keeps the machine up with the API paused. Authenticate once, then restart:

```
fly ssh console -a heywoodlh-lumo-tamer
cd /app && tamer auth login
exit
fly apps restart heywoodlh-lumo-tamer
```

If Proton returns a CAPTCHA, authenticate on a workstation instead and import the vault. Chrome only needs its CDP port on loopback, so no inbound Tailscale ACL is required:

```
open -na "Google Chrome" --args --remote-debugging-port=9222 --user-data-dir="$HOME/.cache/proton-auth-profile"
# log in at https://lumo.proton.me, then, with config.yaml/paths in a temp dir:
tamer auth browser            # endpoint http://127.0.0.1:9222
fly sftp shell -a heywoodlh-lumo-tamer
put /tmp/lumo-auth/vault.enc /app/data/sessions/vault.enc
```

The local vault must be encrypted with the same `LUMO_VAULT_KEY` (`op item get qp43o4locdg7gq64nhl5apqcoe --reveal --fields vault-key`). Restart after the upload; the vault records `method: browser`, so the machine refreshes on its own. Browser auth is the only method that supports conversation sync; `tamer auth rclone` in the machine is the CAPTCHA-free fallback without it.

Tailscale state, `config.yaml` and `sessions/vault.enc` live on the `data` volume, so the node identity and the Proton session survive restarts and redeploys. Fly only attaches a volume to one machine, so keep the app at a single machine.

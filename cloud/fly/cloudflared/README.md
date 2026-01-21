Tailscale-enabled cloudflared deployment on fly.io.

```
fly launch --no-deploy --copy-config
flyctl secrets set TAILSCALE_AUTHKEY="SOMEKEY"
flyctl secrets set CLOUDFLARE_TOKEN="SOMEKEY"
fly deploy
```

On the prompt to tweak settings, press "yes", set port to 0.

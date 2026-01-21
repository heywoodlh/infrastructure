FROM docker.io/alpine:3.23.2

ARG cloudflared_version="2026.1.1"

RUN apk add --no-cache ca-certificates iptables ip6tables
COPY  ./start.sh /start.sh

# Copy Tailscale binaries from the tailscale image on Docker Hub.
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /tailscale/tailscaled
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /tailscale/tailscale

ADD https://github.com/cloudflare/cloudflared/releases/download/${cloudflared_version}/cloudflared-linux-amd64 /usr/bin/cloudflared
RUN chmod +x /usr/bin/cloudflared

RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

# Run on container startup.
CMD ["/start.sh"]


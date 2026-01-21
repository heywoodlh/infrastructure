FROM docker.io/louislam/uptime-kuma:2.0.2
RUN apt update && apt install -y iptables && rm -rf /var/lib/apt/lists/*

COPY  ./start.sh /start.sh

# Copy Tailscale binaries from the tailscale image on Docker Hub.
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /tailscale/tailscaled
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /tailscale/tailscale
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

# Run on container startup.
CMD ["/start.sh"]


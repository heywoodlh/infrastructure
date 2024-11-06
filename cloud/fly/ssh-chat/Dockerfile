FROM docker.io/heywoodlh/ssh-chat

# Copy Tailscale binaries from the tailscale image on Docker Hub.
RUN mkdir -p /app /var/run/tailscale /var/cache/tailscale /var/lib/tailscale
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /app/tailscaled
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /app/tailscale

# Set up SSH
COPY admin_authorized_keys /opt/admin_authorized_keys
COPY authorized_keys /opt/authorized_keys
COPY motd.txt /opt/motd.txt
COPY run.sh /run.sh
COPY keys /data/ssh

RUN mkdir -p /root/ssh
VOLUME /root/ssh

EXPOSE 22

ENTRYPOINT ["ash", "/run.sh"]

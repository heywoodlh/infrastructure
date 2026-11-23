# lumo-tamer on fly.io with Tailscale
#
# Builds upstream lumo-tamer from a pinned commit. The image intentionally does
# not bundle a browser: the "browser" auth method is not usable here, so auth is
# done with "login" or "rclone" (or by importing a vault built elsewhere).

ARG LUMO_TAMER_COMMIT=0ef587b7f3d5d5165914602f0cc79bdfe7ee4e30

# ============================================================================
# Source stage - fetch the pinned upstream tree
# ============================================================================
FROM node:22-alpine AS source

ARG LUMO_TAMER_COMMIT

RUN apk add --no-cache curl

WORKDIR /src

ADD https://github.com/ZeroTricks/lumo-tamer/archive/${LUMO_TAMER_COMMIT}.tar.gz /tmp/lumo-tamer.tar.gz
RUN tar -xzf /tmp/lumo-tamer.tar.gz --strip-components=1 -C /src && rm /tmp/lumo-tamer.tar.gz

# ============================================================================
# Go builder - compile the Proton SRP login helper
# ============================================================================
FROM golang:1.24-alpine AS go-builder

WORKDIR /build

COPY --from=source /src/src/auth/login/go ./
RUN CGO_ENABLED=0 go build -o proton-auth

# ============================================================================
# Node builder - compile TypeScript
# ============================================================================
FROM node:22-alpine AS builder

# Browser binaries are never used in this image: Playwright only talks to an
# external CDP endpoint.
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

RUN apk add --no-cache python3 py3-setuptools make g++ libc6-compat \
    cairo-dev pango-dev jpeg-dev giflib-dev librsvg-dev

WORKDIR /app

COPY --from=source /src/package.json /src/package-lock.json /src/tsconfig.json ./
COPY --from=source /src/packages ./packages

RUN npm ci

COPY --from=source /src/src ./src

RUN npm run build && npm prune --production

# ============================================================================
# Tailscale binaries
# ============================================================================
FROM docker.io/tailscale/tailscale:v1.104.7 AS tailscale

# ============================================================================
# Final stage
# ============================================================================
FROM node:22-alpine

RUN apk add --no-cache ca-certificates iptables ip6tables

COPY --from=tailscale /usr/local/bin/tailscaled /tailscale/tailscaled
COPY --from=tailscale /usr/local/bin/tailscale /tailscale/tailscale

RUN mkdir -p /var/run/tailscale /app/data

WORKDIR /app

COPY --from=source /src/package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=source /src/config.defaults.yaml ./
COPY --from=go-builder /build/proton-auth ./dist/proton-auth

RUN npm link

COPY ./start.sh /start.sh
RUN chmod +x /start.sh

ENV NODE_ENV=production

# Not published to Fly's proxy: the API is reachable over the tailnet only.
EXPOSE 80

CMD ["/start.sh"]

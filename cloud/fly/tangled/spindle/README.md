Community image of [Spindle](https://docs.tangled.org/spindles), [tangled.org](https://tangled.org)'s CI runner.

Features:
- Unprivileged user
- Docker in Docker configuration

---

Dockerfile: https://tangled.org/heywoodlh.io/infrastructure/blob/main/cloud/fly/tangled/spindle/Dockerfile

Pipeline definition to build and push the image: https://tangled.org/heywoodlh.io/infrastructure/blob/main/.tangled/workflows/spindle.yml

Docker Hub image: [heywoodlh/spindle](https://hub.docker.com/r/heywoodlh/spindle)

## Docker-Compose

See [docker-compose.yml](https://tangled.org/heywoodlh.io/infrastructure/tree/main/cloud/fly/tangled/spindle)

## Deploy on Fly.io

See [fly.io assets](https://tangled.org/heywoodlh.io/infrastructure/tree/main/cloud/fly/tangled/spindle)

```
fly launch
```

## Kubernetes

See [spindle.yaml](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/flakes/kube/manifests/spindle.yaml)

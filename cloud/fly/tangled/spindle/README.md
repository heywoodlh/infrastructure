Community image of [Spindle](), CI runner on [tangled.org](https://tangled.org)

> CAUTION: ensure that this container runs in a context where other users cannot execute pipelines, i.e. pull requests

Features:
- Unprivileged user
- Docker in Docker configuration

Dockerfile: https://tangled.org/heywoodlh.io/infrastructure/blob/main/cloud/fly/tangled/spindle/Dockerfile

Pipeline definition to build and push the image: https://tangled.org/heywoodlh.io/infrastructure/blob/main/.tangled/workflows/spindle.yml

## Docker-Compose

See [docker-compose.yml](https://tangled.org/heywoodlh.io/infrastructure/tree/main/cloud/fly/tangled/spindle)

## Deploy on Fly.io:

See [fly.io assets](https://tangled.org/heywoodlh.io/infrastructure/tree/main/cloud/fly/tangled/spindle)

```
fly launch
```

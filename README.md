# Build the NixOS cloud-init image

nix build .#image.x86_64-linux

# Git forge mirroring

Pushes to GitHub `main` are fast-forwarded to Tangled `main` by `.github/workflows/sync-tangled.yml`. Configure the `TANGLED_SSH_PRIVATE_KEY` repository secret with a key that has write access to `git@tangled.org:heywoodlh.io/infrastructure` before merging. If Tangled `main` diverges, its normal non-force push rejects the update; reconcile the history explicitly instead of overwriting either forge.

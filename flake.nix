{
  description = "infrastructure";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      #pkgs = nixpkgs.legacyPackages.${system};
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      tf = pkgs.writeShellScriptBin "tf" ''
        ${pkgs.opentofu}/bin/tofu $@
      '';
      terraform = pkgs.writeShellScriptBin "terraform" ''
        ${pkgs.opentofu}/bin/tofu $@
      '';

      inherit (pkgs) lib;
      arch = if pkgs.lib.hasInfix "aarch64" "${system}" then "aarch64" else "x86_64";
      linuxSystem = "${arch}-linux";

      baseModule = { lib, config, pkgs, ...}: {
        nixpkgs.hostPlatform = "${linuxSystem}";
        imports = [
          "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
        ];

        networking = {
          hostName = "nixos-cloudinit";
        };

        fileSystems."/" = {
          label = "nixos";
          fsType = "ext4";
          autoResize = true;
        };
        boot.loader.grub.device = "/dev/sda";
        services.openssh.enable = true;
        services.qemuGuest.enable = true;
        security.sudo.wheelNeedsPassword = false;

        users.users.heywoodlh = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
        };

        networking = {
          dhcpcd.enable = true;
          interfaces.eth0.useDHCP = false;
        };

        systemd.network.enable = true;

        services.cloud-init = {
          enable = true;
          network.enable = true;
          config = ''
            system_info:
              distro: nixos
              network:
                renderers: [ 'networkd' ]
              default_user:
                name: heywoodlh
            users:
                - default
            ssh_pwauth: false
            chpasswd:
              expire: false
            cloud_init_modules:
              - migrator
              - seed_random
              - growpart
              - resizefs
            cloud_config_modules:
              - disk_setup
              - mounts
              - set-passwords
              - ssh
            cloud_final_modules: []
            '';
        };
      };

      nixos = nixpkgs.lib.nixosSystem {
        modules = [baseModule];
      };

      make-disk-image = import "${nixpkgs}/nixos/lib/make-disk-image.nix";

    in {
      devShell = pkgs.mkShell {
        name = "infrastructure";
        buildInputs = with pkgs; [
          _1password
          opentofu
          fish
          talosctl
          terraform
          tf
        ];
      };

      image = make-disk-image {
        inherit pkgs lib;
        config = nixos.config;
        name = "nixos-cloudinit";
        format = "qcow2-compressed";
        copyChannel = false;
      };
      formatter = pkgs.alejandra;
    });
}

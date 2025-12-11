{
  description = "infrastructure";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.fish-flake.url = "github:heywoodlh/nixos-configs?dir=flakes/fish";

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    fish-flake,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      #pkgs = nixpkgs.legacyPackages.${system};
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      op-wrapper = fish-flake.packages.${system}.op-wrapper;
      tf = pkgs.writeShellScriptBin "tf" ''
        ${pkgs.opentofu}/bin/tofu $@
      '';
      terraform = pkgs.writeShellScriptBin "terraform" ''
        ${pkgs.opentofu}/bin/tofu $@
      '';
      hcloud-wrapper = pkgs.writeShellScriptBin "hcloud" ''
        test -z "$HCLOUD_TOKEN" && export HCLOUD_TOKEN="$(${op-wrapper}/bin/op-wrapper item get azutrtibatixkvxl662nqrkyj4 --reveal --fields=password)"
        ${pkgs.hcloud}/bin/hcloud $@
      '';
    in {
      devShell = pkgs.mkShell {
        name = "infrastructure";
        buildInputs = with pkgs; [
          op-wrapper
          opentofu
          fish
          flyctl
          hcloud-wrapper
          p7zip
          terraform
          tf
          vultr-cli
        ];
      };
      formatter = pkgs.alejandra;
    });
}

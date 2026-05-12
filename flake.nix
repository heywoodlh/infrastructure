{
  description = "infrastructure";

  inputs.nixos-configs.url = "git+https://tangled.org/heywoodlh.io/nixos-configs";

  outputs = {
    self,
    nixos-configs,
  }:
    nixos-configs.inputs.flake-utils.lib.eachDefaultSystem (system: let
      nixpkgs = nixos-configs.inputs.nixpkgs;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      tangled-sync = nixos-configs.packages.${system}.tangled-sync;
      op-wrapper = nixos-configs.packages.${system}.op-wrapper;
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
          terraform-ls
          vultr-cli
        ];
        shellHook = ''
          ${tangled-sync}/bin/tangled-sync.sh
        '';
      };
      formatter = pkgs.alejandra;
    });
}

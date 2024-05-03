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

      formatter = pkgs.alejandra;
    });
}

{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay.url = "github:oxalica/rust-overlay";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];
      systems = [
        "x86_64-linux" 
        "aarch64-linux" 
        "x86_64-darwin" 
        "aarch64-darwin" 
      ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = with inputs; [
            rust-overlay.overlays.default
          ];
        };
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            ((
              pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml
             ).override {
               extensions = [
                 "rust-src"
                 "rust-analyzer"
                 "rust-analysis"
                 "clippy"
               ];
             })
          ];
        };
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}

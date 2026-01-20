{
  description = "agentica-mini Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        nix_tools = with pkgs; [
          alejandra # Nix code formatter.
          statix # Nix static code checker
          deadnix # Nix dead code checker
        ];
        python_tools = with pkgs; [
          ty
          uv
          ruff
        ];
      in {
        # Build packages with `nix build .#inference` for example.
        packages = { };

        # Enter reproducible development shell with `nix develop`
        devShells = {
          default = pkgs.mkShell {
            buildInputs = nix_tools ++ python_tools;
          };
        };

        # Apps can be run with `nix run`
        apps = {};
      }
    );
}

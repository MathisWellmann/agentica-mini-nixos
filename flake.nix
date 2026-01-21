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

        deps = with pkgs; [
          cacert # for SSL certificates.
          pkg-config
          openssl
        ];
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
        packages = {};

        # Enter reproducible development shell with `nix develop`
        devShells = {
          default = pkgs.mkShell {
            buildInputs = deps ++ nix_tools ++ python_tools;
            shellHook = ''
              export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              export NIX_SSL_CERT_FILE="$SSL_CERT_FILE"
            '';
          };
        };

        # Apps can be run with `nix run`
        apps = rec {
          default = chat;
          chat = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "chat" ''
              nix develop --command uv run python -m chat
            '';
          };
        };
      }
    );
}

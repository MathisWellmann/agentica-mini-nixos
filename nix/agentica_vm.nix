# Build and run with `nix-build nix/agentica_vm.nix; result/bin/run-agentica-vm`
# The jupyter notebook will be available on `127.0.0.1:8888` on the host.
#
# Some trouble shooting steps (TODO: don't run into any of these issues):
# - If you do `uv run python -m chat`, but get the error "Failed to canonicalize path /root/.venv/bin/python3: Too many levels of symbolic links"
#   Then These steps help:
#   rm -rf .venv
#   uv venv --python $(which python3)
#   uv run python -m chat

let
  pkgs = import <nixpkgs> {};

  agentica_vm = {...}: let
    port = 8888;
  in {
    boot = {
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
      initrd.systemd.enable = true;
    };

    services = {
      getty.autologinUser = "root";
      # jupyter = {
      #   enable = true;
      #   inherit port;
      #   ip = "0.0.0.0";
      #   # Disable both token and password.
      #   password = "";
      #   command = "jupyter notebook --NotebookApp.token='' --NotebookApp.password='' ";
      # };
    };
    programs.nix-ld.enable = true; # Enables running dynamically linked libraries like uv
    networking = {
      hostName = "agentica";
      # firewall.allowedTCPPorts = [port];
      # interfaces.eth0.ipv4.addresses = [
      #   {
      #     address = "192.168.0.124";
      #     prefixLength = 24;
      #   }
      # ];
    };
    environment = {
      systemPackages = with pkgs; [
        # (python3.withPackages (python-pkgs: with python-pkgs; [
        #   numpy
        # ]))
        python3
        uv
        neofetch
        ripgrep
      ];
      variables = {
        PYTHONPATH="${pkgs.python3}";
      };
    };
    virtualisation = {
      diskSize = 2048;
      vmVariant.virtualisation = {
        qemu.options = [
          # This enables port forwarding
          "-netdev"
          "user,id=net0,hostfwd=tcp::${toString port}-:${toString port}"
        ];
        sharedDirectories = {
          share = {
            source = "${toString ./../python_agent}";
            target = "/root";
          };
        };
      };
    };
  };
  vms = pkgs.nixos [
    agentica_vm
  ];
in
  vms.config.system.build.vm

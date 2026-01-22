# Build and run with `nix-build nix/agentica_vm.nix; result/bin/run-agentica-vm`
# The jupyter notebook will be available on `127.0.0.1:8888` on the host.
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
      jupyter = {
        enable = true;
        inherit port;
        ip = "0.0.0.0";
        # Disable both token and password.
        password = "";
        command = "jupyter notebook --NotebookApp.token='' --NotebookApp.password='' ";
      };
    };
    networking = {
      hostName = "agentica";
      firewall.allowedTCPPorts = [port];
      interfaces.eth0.ipv4.addresses = [
        {
          address = "192.168.0.124";
          prefixLength = 24;
        }
      ];
    };
    environment.systemPackages = with pkgs; [
      uv
      neofetch
      ripgrep
    ];
    virtualisation = {
      diskSize = 2048;
      # This enables port forwarding
      vmVariant.virtualisation = {
        qemu.options = [
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

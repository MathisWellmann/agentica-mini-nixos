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
      supportedFilesystems = [ "9p" "9p2000" ];
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
    ];
    # Mount the host directory `vm_persistent_state` into the VM  at `/mnt/vm_persistent_state` for persistent agent storage.
    fileSystems."/mnt/shared" = {
      device = "hostshare"; # must match the 'security.model' name in qemu
      fsType = "9p";
      options = [
        "trans=virtio"
        "version=9p2000.L"
      ];
    };
    virtualisation = {
      diskSize = 2048;
      # This enables port forwarding
      vmVariant.virtualisation.qemu.options = [
        "-netdev" "user,id=net0,hostfwd=tcp::${toString port}-:${toString port}"
        "-device" "virtio-net-pci,netdev=net0"
        "-virtfs local,path=${toString ./../hostshare},mount_tag=hostshare,security_model=mapped-xattr,id=hostshare"
      ];
    };
  };
  vms = pkgs.nixos [
    agentica_vm
  ];
in
  vms.config.system.build.vm

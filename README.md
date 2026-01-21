Agentica Mini Nixos Showcase
============================

Use `agentica` to fully control a Linux system including:

 -  Installing arbitrary nix packages in the system, for the agent to use.
 -  Enable systemd services and expose their functionality, so the agent can use
    them in the native python environment.
 -  Run arbitrary shell commands to make this all work.
 -  Isolated in QEMU VM

### Build with [Nix]

 -  Make sure you have `nix` installed or install it with:

    ~~~~ shell
    sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
    ~~~~
 -  Now simply run it with:
     -  `nix run github:MathisWellmann/agentica-mini-nixos`, which will fetch the git
        repo automatically and run it.
     -  Or locally in the repo with `nix run`

All required build dependencies are packaged reproducibly and defined in
`flake.nix`. A development shell is included and can be accessed by running
`nix develop` or use `direnv allow` if available.

[Nix]: https://nixos.org/

### TODOs:

Cool things that this should enable:

 -  Install arbitrary python packages simply by asking the agent to install it.
    E.g.: “Please import numpy and install it if necessary”
 -  Run any service in the VM and optionally expose it to the outside, by editing
    the NixOS config. E.g.: “Please enable the redis service and store 100 keys
    with random values in it”
 -  Use system dependencies like `gnuplot` seamlessly:
    E.g.: “Please plot all the redis keys and values in a gnuplot chart”

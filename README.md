Agentica Mini NixOS Showcase
============================

> [!IMPORTANT]
> This is a work-in-progress prototype and only public to make it easy to talk
> about. Expect nothing to work.

Use [`agentica`] to fully control a Linux system including:

 -  Provide a python repl chat interface for instructing the Agent to do things.
 -  Installing and importing arbitrary python packages, including ones with system
    dependencies.
 -  Installing arbitrary nix packages in the system, for the agent to use, e.g
    `neofetch`
 -  Run systemd services, so the agent can use
    them in the native python environment, e.g.: `redis`, `postgresql`
 -  Expose the systemd services from the VM, so users can interact with those
    services.
 -  Run arbitrary shell commands to make this all work.
 -  Isolated in QEMU VM

[`agentica`]: https://www.symbolica.ai/agentica

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

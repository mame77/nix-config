{ pkgs, ... }:

let
  # Strip the `doc` output from python to avoid collision with another
  # python in the closure (e.g. build-time tools).
  python = pkgs.python312.overrideAttrs (old: {
    passthru = pkgs.lib.filterAttrs (name: _: name != "doc") old.passthru;
  });
in
{
  users.users.mame.packages = with pkgs; [
    # dev — language toolchains
    go
    python
    nodejs
    bun
    pnpm
    uv

    # dev — build tooling
    gcc
    gnumake
    pkg-config

    # dev — VCS
    git
    gh

    # dev — editors / multiplexers
    vim
    neovim
    tmux

    # dev — search / nav
    ripgrep
    fd
    jq
    tree
    fzf

    # dev — shell / direnv
    direnv
    nix-direnv

    # dev — TUIs
    lazygit
    lazydocker
    lazysql
    ghq
  ];
}

{ pkgs, inputs, ... }:

let
  # python in the closure (e.g. build-time tools).
  python = pkgs.python312.overrideAttrs (old: {
    passthru = pkgs.lib.filterAttrs (name: _: name != "doc") old.passthru;
  });
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  users.users.mame.packages = with pkgs; [
    # language toolchains
    go
    python
    nodejs
    bun
    pnpm
    uv

    # build tooling
    gcc
    gnumake
    pkg-config

    # git
    git
    gh
    ghq

    # editors / multiplexers
    vim
    neovim
    tmux

    # search / nav
    ripgrep
    fd
    jq
    tree
    fzf

    # shell / direnv
    direnv
    nix-direnv

    # TUIs
    lazygit
    lazydocker
    lazysql

    # llm agents
    llmAgents.opencode
    llmAgents.grok
    llmAgents.codex

    # cloud / db clis
    supabase-cli
  ];
}

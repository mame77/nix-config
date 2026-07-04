{ pkgs, inputs, ... }:

let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  python = pkgs.python312.overrideAttrs (old: {
    passthru = pkgs.lib.filterAttrs (name: _: name != "doc") old.passthru;
  });
in
{
  users.users.mame.packages = with pkgs; [
    go
    git
    vim
    neovim
    tmux
    tree
    nodejs
    bun
    pnpm
    python
    uv
    gcc
    gnumake
    pkg-config
    ripgrep
    fd
    jq
    direnv
    nix-direnv
    lazygit
    lazydocker
    lazysql
    ghq
    fzf
    niri
    ghostty
  ] ++ [
    llmAgents.opencode
    llmAgents.grok
  ];
}

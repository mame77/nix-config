{ pkgs, inputs, ... }:

let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  python = pkgs.python312.overrideAttrs (old: {
    passthru = pkgs.lib.filterAttrs (name: _: name != "doc") old.passthru;
  });
in
{
  users.users.mame.packages = with pkgs; [
    # dev
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
    # compositor & shell
    niri
    ghostty
    tuigreet
    # wayland / desktop
    wlogout
    fuzzel
    grim
    slurp
    wl-clipboard
    wf-recorder
    wl-mirror
    xdg-utils
    # input method
    fcitx5
    fcitx5-gtk
    libsForQt5.fcitx5-qt
    # terminal apps
    btop
    bluetuith
    wiremix
    impala
    # utilities
    brightnessctl
    libnotify
    # browser
    vivaldi
  ] ++ [
    llmAgents.opencode
    llmAgents.grok
  ];
}

{ pkgs, inputs, config, ... }:

let
  pythonWithPkgs = (pkgs.python312.withPackages (ps: with ps; [
    python-pptx
    openpyxl
  ])).overrideAttrs (old: {
    passthru = pkgs.lib.filterAttrs (name: _: name != "doc") old.passthru;
  });
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  herdr = pkgs.callPackage ../packages/herdr.nix {};
in
{
  security.sudo.extraRules = [
    {
      users = [ "mame" ];
      commands = [
        {
          command = "${config.system.build.nixos-rebuild}/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  users.users.mame.packages = with pkgs; [
    # language toolchains
    go
    pythonWithPkgs
    nodejs
    bun
    pnpm
    uv

    # build tooling
    gcc
    gnumake
    openssl
    pkg-config

    # git
    git
    gh
    ghq

    # editors / multiplexers
    vim
    neovim
    tmux

    # nvim-treesitter runtime compile
    tree-sitter

    # search / nav
    ripgrep
    fd
    jq
    tree
    fzf

    # shell / direnv
    direnv
    nix-direnv

    # tool version manager
    mise

    # TUIs
    lazygit
    lazydocker
    lazysql

    # llm agents
    llmAgents.opencode
    llmAgents.grok
    llmAgents.codex

    # agent multiplexer
    herdr

    # cloud / db clis
    supabase-cli
    wrangler
    xdg-utils
  ];
}

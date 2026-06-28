{ pkgs, inputs, ... }:

{
  imports = [
    ./default.nix
    ../../modules/home-manager/dev.nix
    ../../modules/home-manager/nvim.nix
    ../../modules/home-manager/tmux.nix
  ];

  home.packages = with pkgs; [
    git
    vim
    neovim
    tmux
    tree
  ] ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    opencode
    grok
  ]);
}
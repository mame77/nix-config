{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ../../dotfiles/tmux/tmux.conf;
  };

  home.packages = with pkgs; [
    lazygit
    lazydocker
    lazysql
  ];
}
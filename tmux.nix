{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./tmux/tmux.conf;
  };

  environment.systemPackages = with pkgs; [
    lazygit
    lazydocker
    lazysql
  ];
}
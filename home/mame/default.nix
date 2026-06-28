{ ... }:

{
  home.username = "mame";
  home.homeDirectory = "/home/mame";
  home.stateVersion = "26.05";

  imports = [
    ../../modules/home-manager/bash.nix
  ];

  programs.home-manager.enable = true;
}
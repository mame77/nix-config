{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ../../modules/niri.nix
    ../../modules/noctalia.nix
    ../../modules/fcitx5.nix
  ];

  networking.hostName = "laptop";
}
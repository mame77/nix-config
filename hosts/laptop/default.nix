{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ../../modules/niri.nix
    ../../modules/noctalia.nix
  ];

  networking.hostName = "laptop";
}
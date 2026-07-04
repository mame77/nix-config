{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ../../modules/niri.nix
  ];

  networking.hostName = "laptop";
}
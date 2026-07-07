{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/system-server.nix
    ../../modules/dev.nix
    ../../home/common.nix
  ];

  networking.hostName = "server";
}

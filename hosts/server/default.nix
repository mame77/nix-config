{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/system-server.nix
    ../../modules/dev.nix
  ];

  networking.hostName = "server";
}

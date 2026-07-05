{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/base.nix
    ../../profiles/server.nix
  ];

  networking.hostName = "server";
}

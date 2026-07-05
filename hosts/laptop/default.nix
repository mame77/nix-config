{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/base.nix
    ../../profiles/laptop.nix
    ../../profiles/dev.nix
  ];

  networking.hostName = "laptop";
}

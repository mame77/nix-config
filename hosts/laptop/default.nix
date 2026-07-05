{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/system-laptop.nix
    ../../modules/dev.nix
    ../../modules/tool.nix
    ../../home/default.nix
  ];

  networking.hostName = "laptop";
}

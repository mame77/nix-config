{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/system-laptop.nix
    ../../modules/dev.nix
    ../../modules/tool.nix
    ../../home/common.nix
    ../../home/laptop.nix
    inputs.openwhispr.nixosModules.default
  ];

  networking.hostName = "laptop";

  programs.openwhispr = {
    enable = true;
    users = [ "mame" ];
  };
}
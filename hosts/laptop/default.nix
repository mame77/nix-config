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
    inputs.handy.nixosModules.default
  ];

  networking.hostName = "laptop";

  programs.handy.enable = true;
}

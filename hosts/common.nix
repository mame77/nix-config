{ inputs, pkgs, ... }:

{
  imports = [
    ../modules/core.nix
    ../modules/env.nix
    ../modules/pkgs.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    curl
  ];

  system.stateVersion = "26.05";
}
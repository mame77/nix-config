{ inputs, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../modules/nixos/core.nix
    ../modules/nixos/users.nix
    ../modules/nixos/openssh.nix
    ../modules/nixos/tailscale.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    curl
  ];

  system.stateVersion = "26.05";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.mame = import ../home/mame/home.nix;
}
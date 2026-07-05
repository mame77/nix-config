{ ... }:

{
  imports = [
    ../modules/system/bootloader.nix
    ../modules/system/networking.nix
    ../modules/system/locale.nix
    ../modules/system/users.nix
    ../modules/system/docker.nix
    ../modules/services/openssh.nix
    ../modules/services/tailscale.nix
    ../modules/packages/base.nix
  ];

  system.stateVersion = "26.05";
}

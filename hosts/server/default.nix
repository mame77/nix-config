{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/system-server.nix
    ../../modules/dev.nix
    ../../modules/android.nix
    ../../modules/server-desktop.nix
    ../../modules/orca-serve.nix
    ../../home/common.nix
    ../../home/server.nix
  ];

  networking.hostName = "server";

  # Allow passwordless administration for mame on this host only.
  security.sudo.extraRules = [
    {
      users = [ "mame" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
  ];
}

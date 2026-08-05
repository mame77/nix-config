{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/system-server.nix
    ../../modules/dev.nix
    ../../modules/orca-serve.nix
    ../../home/common.nix
  ];

  networking.hostName = "server";

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
  ];
}

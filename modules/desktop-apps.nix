{ pkgs, ... }:

let
  opencode-desktop = pkgs.callPackage ../packages/opencode-desktop.nix {};
  orca-desktop = pkgs.callPackage ../packages/orca-desktop.nix {};
in
{
  users.users.mame.packages = with pkgs; [
    ghostty
    foot
    google-chrome
    bitwarden-desktop
    bitwarden-cli
    btop
    libnotify
    obsidian
    opencode-desktop
    orca-desktop
  ];
}

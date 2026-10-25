{ config, pkgs, ... }:

let
  opencode-desktop = pkgs.callPackage ../packages/opencode-desktop.nix {};
  orca-desktop = pkgs.callPackage ../packages/orca-desktop.nix {};
  chrome = if config.networking.hostName == "server" then
    pkgs.google-chrome.override {
      commandLineArgs = "--force-renderer-accessibility";
    }
  else pkgs.google-chrome;
in
{
  users.users.mame.packages = with pkgs; [
    ghostty
    foot
    chrome
    bitwarden-cli
    btop
    libnotify
    obsidian
    opencode-desktop
    orca-desktop
  ] ++ pkgs.lib.optionals (config.networking.hostName != "server") [
    pkgs.bitwarden-desktop
  ];
}

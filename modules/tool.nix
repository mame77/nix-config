{ pkgs, ... }:

let
  remoteClients = import ../packages/remote-clients.nix { inherit pkgs; };
in
{
  imports = [ ./desktop-apps.nix ];

  users.users.mame.packages = with pkgs; [
    # compositor & shell
    niri
    tuigreet

    # wayland utilities
    wlogout
    fuzzel
    grim
    slurp
    wl-clipboard
    wf-recorder
    wl-mirror
    wtype
    xdotool
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    xdg-utils

    # terminal / system TUIs
    bluetuith
    wiremix
    impala

    # utilities
    brightnessctl
    # Clients for the development server's desktop and Android display.
    tigervnc
    remoteClients.server-desktop
    remoteClients.server-android
  ];
}

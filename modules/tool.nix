{ pkgs, ... }:

{
  users.users.mame.packages = with pkgs; [
    # compositor & shell
    niri
    ghostty
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
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    xdg-utils

    # browser
    vivaldi

    # terminal / system TUIs
    btop
    fastfetch
    bluetuith
    wiremix
    impala

    # utilities
    brightnessctl
    libnotify
    obsidian
  ];
}

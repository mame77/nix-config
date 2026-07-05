{ pkgs, ... }:

{
  users.users.mame.packages = with pkgs; [
    # terminal / system TUIs
    btop
    bluetuith
    wiremix
    impala

    # utilities
    brightnessctl
    libnotify
  ];
}

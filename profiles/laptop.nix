{ ... }:

{
  imports = [
    ../modules/desktop/niri.nix
    ../modules/desktop/noctalia.nix
    ../modules/desktop/fcitx5.nix
    ../modules/system/bluetooth.nix
    ../modules/system/upower.nix
    ../modules/packages/desktop-gui.nix
    ../modules/packages/desktop-cli.nix
    ../modules/packages/llm-agents.nix
  ];

  # xkb layout for the (X) login / fallback path. The niri-side layout
  # is configured in niri/config.kdl.
  services.xserver.xkb = {
    layout = "us";
    options = "ctrl:nocaps";
  };

  users.users.mame.extraGroups = [ "bluetooth" ];
}

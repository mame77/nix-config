{ ... }:

{
  imports = [ ./desktop.nix ];

  # Preserve pre-existing imperative files when bringing them under management.
  home-manager.backupFileExtension = "before-server-desktop";

  home-manager.users.mame = { ... }: {
    home.file.".agents/skills/orca-computer-use/SKILL.md".source =
      ../dotfiles/agents/skills/orca-computer-use/SKILL.md;
    home.file.".agents/skills/android-emulator-use/SKILL.md".source =
      ../dotfiles/agents/skills/android-emulator-use/SKILL.md;

    # Select Japanese/English explicitly with the left/right Alt keys, and
    # preserve the mode when moving between application windows.
    xdg.configFile."fcitx5/config".text = ''
      [Hotkey/TriggerKeys]

      [Hotkey/AltTriggerKeys]

      [Hotkey/ActivateKeys]
      0=Alt_L

      [Hotkey/DeactivateKeys]
      0=Alt_R

      [Behavior]
      ShareInputState=All
    '';

    # Fcitx is normally started by niri on the laptop. Xfce uses XDG autostart.
    xdg.configFile."autostart/org.fcitx.Fcitx5.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Fcitx 5
      Exec=fcitx5
      OnlyShowIn=XFCE;
    '';

    home.sessionVariables = {
      # These match the persistent desktop, so SSH-launched development tools
      # and accessibility clients operate on the screen shown through VNC.
      DISPLAY = ":99";
      DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
    };
    gtk = {
      enable = true;
      theme.name = "Adwaita-dark";
      font.name = "UDEV Gothic NF 11";
    };
    dconf.settings."org/gnome/desktop/interface".toolkit-accessibility = true;
  };
}

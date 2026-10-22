{ ... }:

{
  imports = [ ./desktop.nix ];

  # Preserve pre-existing imperative files when bringing them under management.
  home-manager.backupFileExtension = "before-server-desktop";

  home-manager.users.mame = { ... }: {
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

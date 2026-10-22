{ config, pkgs, ... }:

let
  uid = "1000";
  gtkInputPath = "${config.i18n.inputMethod.package}/lib/gtk-3.0:${config.i18n.inputMethod.package}/lib/gtk-4.0:/run/current-system/sw/lib/gtk-3.0:/run/current-system/sw/lib/gtk-4.0";
  desktopEnvironment = {
    DISPLAY = ":99";
    XDG_RUNTIME_DIR = "/run/user/${uid}";
    DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/${uid}/bus";
    XDG_CURRENT_DESKTOP = "XFCE";
    XDG_CONFIG_DIRS = "/etc/xdg";
    XDG_SESSION_TYPE = "x11";
    GDK_BACKEND = "x11";
    QT_QPA_PLATFORM = "xcb";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    LIBGL_ALWAYS_SOFTWARE = "1";
  };
  desktopPath = [
    "/etc/profiles/per-user/mame/bin"
    "/run/current-system/sw/bin"
    "/run/wrappers/bin"
  ];
in
{
  imports = [ ./system-desktop.nix ./desktop-apps.nix ];

  # Keep the existing user bus available even when the SSH client disconnects.
  users.users.mame = {
    uid = 1000;
    linger = true;
  };

  services.xserver.desktopManager.xfce = {
    enable = true;
    enableScreensaver = false;
  };
  hardware.graphics.enable = true;
  security.polkit.enable = true;
  systemd.tmpfiles.rules = [ "d /tmp/.ICE-unix 1777 root root -" ];
  services.gnome.gnome-keyring.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };

  # The Orca runtime and VNC attach to this same X display, rather than creating
  # separate remote-login desktops that cannot see each other's applications.
  systemd.services.server-desktop = {
    description = "Persistent development desktop";
    # Keep open applications alive during rebuilds. Environment changes take
    # effect in a new desktop session; reopen affected apps with the new env.
    restartIfChanged = false;
    wantedBy = [ "multi-user.target" ];
    requires = [ "orca-xvfb.service" "user@${uid}.service" ];
    wants = [ "home-manager-mame.service" ];
    after = [ "orca-xvfb.service" "user@${uid}.service" "home-manager-mame.service" ];
    environment = desktopEnvironment // {
      PATH = pkgs.lib.mkForce (pkgs.lib.concatStringsSep ":" desktopPath);
      XDG_DATA_DIRS = "${config.i18n.inputMethod.package}/share:/run/current-system/sw/share:/etc/profiles/per-user/mame/share";
      # System services bypass /etc/profile. GTK apps need these paths to find
      # Fcitx's input module, even when GTK_IM_MODULE is already set correctly.
      GTK_PATH = gtkInputPath;
      GTK_IM_MODULE_FILE = "/run/current-system/sw/etc/gtk-3.0/immodules.cache";
    };
    preStart = ''
      for attempt in $(seq 1 30); do
        if ${pkgs.xdpyinfo}/bin/xdpyinfo >/dev/null 2>&1; then
          ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd \
            DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_DATA_DIRS XDG_CONFIG_DIRS \
            GDK_BACKEND QT_QPA_PLATFORM GTK_IM_MODULE GTK_PATH GTK_IM_MODULE_FILE QT_IM_MODULE XMODIFIERS PATH
          exit 0
        fi
        sleep 1
      done
      echo "Virtual X display :99 did not become ready" >&2
      exit 1
    '';
    serviceConfig = {
      User = "mame";
      Group = "users";
      WorkingDirectory = "/home/mame";
      ExecStart = "${pkgs.xfce4-session}/bin/xfce4-session";
      Restart = "always";
      RestartSec = 5;
      TimeoutStopSec = 20;
    };
  };

  systemd.services.server-desktop-vnc = {
    description = "Development desktop over an SSH tunnel";
    wantedBy = [ "multi-user.target" ];
    requires = [ "orca-xvfb.service" ];
    after = [ "orca-xvfb.service" "server-desktop.service" ];
    environment = desktopEnvironment;
    serviceConfig = {
      User = "mame";
      Group = "users";
      # TigerVNC's Extended Clipboard preserves UTF-8 text, including Japanese.
      ExecStart = "${pkgs.tigervnc}/bin/x0vncserver -display :99 -localhost -interface 127.0.0.1 -rfbport 5900 -SecurityTypes None -AlwaysShared -AcceptCutText -SendCutText -SetPrimary=0 -SendPrimary=0 -AcceptSetDesktopSize=0";
      Restart = "always";
      RestartSec = 5;
    };
  };

  # Only local SSH forwarding can reach VNC; no public or Tailscale VNC port.
  # Accessibility clients use the same bus and display as the visible desktop.
  systemd.services.orca-serve = {
    requires = [ "user@${uid}.service" ];
    after = [ "user@${uid}.service" "server-desktop.service" ];
    environment = desktopEnvironment // {
      GTK_PATH = gtkInputPath;
      GTK_IM_MODULE_FILE = "/run/current-system/sw/etc/gtk-3.0/immodules.cache";
    };
    serviceConfig.Environment = [ "XDG_DATA_DIRS=/run/current-system/sw/share:/etc/profiles/per-user/mame/share" ];
  };
}

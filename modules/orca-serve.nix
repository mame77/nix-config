{ pkgs, lib, ... }:

let
  orca-desktop = pkgs.callPackage ../packages/orca-desktop.nix {};
  display = ":99";
in
{
  users.users.mame.packages = [ orca-desktop ];

  environment.systemPackages = [
    pkgs.xorg-server # Xvfb for the persistent Orca IDE
  ];

  # Orca's auto-Xvfb may not find the Nix-provided binary; manage display ourselves.
  systemd.services.orca-xvfb = {
    description = "Virtual X display for Orca";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "mame";
      Group = "users";
      ExecStart = "${pkgs.xorg-server}/bin/Xvfb ${display} -screen 0 1920x1080x24 -nolisten tcp";
      Restart = "always";
      RestartSec = 5;
    };
  };

  # Run the full IDE so its account and Orca Relay settings are available.
  # The IDE owns the runtime; do not run a second `orca serve` for this profile.
  systemd.services.orca-desktop = {
    description = "Orca IDE";
    after = [ "network-online.target" "orca-xvfb.service" "server-desktop.service" ];
    wants = [ "network-online.target" "orca-xvfb.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "mame";
      Group = "users";
      WorkingDirectory = "/home/mame";
      Environment = [
        "HOME=/home/mame"
        "DISPLAY=${display}"
        "XDG_RUNTIME_DIR=/run/user/1000"
        "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
        "LIBGL_ALWAYS_SOFTWARE=1"
        "PATH=/etc/profiles/per-user/mame/bin:/run/current-system/sw/bin"
      ];
      ExecStart = "${orca-desktop}/bin/orca-desktop";
      Restart = "always";
      RestartSec = 5;
      StandardOutput = "journal";
      StandardError = "journal";
      # Allow clean stop/restart cycles without leaving the unit dead.
      KillMode = "control-group";
      TimeoutStopSec = 20;
    };
  };
}

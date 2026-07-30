{ pkgs, lib, ... }:

let
  orca-desktop = pkgs.callPackage ../packages/orca-desktop.nix {};
  pairingAddress = "100.77.153.77";
  port = 6768;
  display = ":99";
  readyLog = "/home/mame/.config/orca/serve-ready.jsonl";

  # Electron main expects rewritten flags (--serve-*), not the CLI subcommand form.
  orcaServeScript = pkgs.writeShellScript "orca-serve" ''
    set -euo pipefail
    mkdir -p "$(dirname ${readyLog})"
    : > ${readyLog}
    : > ${readyLog}.err
    exec ${pkgs.coreutils}/bin/stdbuf -oL -eL \
      ${orca-desktop}/bin/orca-desktop \
        --serve \
        --serve-port ${toString port} \
        --serve-pairing-address ${pairingAddress} \
        --serve-mobile-pairing \
        --serve-json \
      2> >( ${pkgs.coreutils}/bin/tee -a ${readyLog}.err >&2 ) \
      | ${pkgs.coreutils}/bin/tee -a ${readyLog}
  '';
in
{
  users.users.mame.packages = [ orca-desktop ];

  environment.systemPackages = [
    pkgs.xorg-server # Xvfb for headless orca serve
  ];

  # Orca's auto-Xvfb may not find the Nix-provided binary; manage display ourselves.
  systemd.services.orca-xvfb = {
    description = "Virtual X display for Orca";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.xorg-server}/bin/Xvfb ${display} -screen 0 1280x1024x24 -nolisten tcp";
      Restart = "always";
      RestartSec = 5;
    };
  };

  systemd.services.orca-serve = {
    description = "Orca runtime server";
    after = [ "network-online.target" "tailscaled.service" "orca-xvfb.service" ];
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
        "LIBGL_ALWAYS_SOFTWARE=1"
        "PATH=/etc/profiles/per-user/mame/bin:/run/current-system/sw/bin"
      ];
      ExecStart = "${orcaServeScript}";
      Restart = "always";
      RestartSec = 5;
      StandardOutput = "journal";
      StandardError = "journal";
      # Allow clean stop/restart cycles without leaving the unit dead.
      KillMode = "control-group";
      TimeoutStopSec = 20;
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}

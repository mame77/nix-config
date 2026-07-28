{ pkgs, lib, ... }:

{
  imports = [ ./immich.nix ];

  # ─── lid switch を無視(サーバは蓋を開けない) ─────
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  # ─── スリープ/サスペンド/ハイバネート を全部無効 ──
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # ─── nix-ld: 動的リンクバイナリを通す ─────────────
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [ stdenv.cc.cc glibc zlib ];

  # ─── TTY auto-login ────────────────────────────────
  systemd.services."getty@tty1".serviceConfig.ExecStart = lib.mkForce [
    ""
    "${lib.getBin pkgs.util-linux}/bin/agetty --autologin mame --noclear %I $TERM"
  ];

  # ─── /data directory structure ─────────────────────
  systemd.services.data-setup = {
    description = "Setup /data directory structure";
    after = [ "data.mount" ];
    requires = [ "data.mount" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /data/{obsidian-vault,media,docs,backups,docker}
      chown -R mame:users /data/obsidian-vault /data/media /data/docs /data/backups /data/docker
      chmod 755 /data/{obsidian-vault,media,docs,docker}
      chmod 700 /data/backups
      ln -sfn /data/obsidian-vault /home/mame/obsidian-vault
    '';
  };

  # ─── NFS server ────────────────────────────────────
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /data 100.64.0.0/10(rw,sync,no_subtree_check,fsid=0,no_root_squash)
  '';

  # ─── Syncthing ─────────────────────────────────────
  # DO NOT change dataDir without migrating cert/key/config.xml.
  # Actual files live at dataDir/.config/syncthing/ (identity, DB, config).
  # Changing dataDir regenerates device ID → breaks pairing with devices.
  services.syncthing = {
    enable = true;
    user = "mame";
    dataDir = "/home/mame/.config/syncthing";
    overrideDevices = false;
    overrideFolders = false;
  };

  # ─── Ollama (OpenWhispr 要約 / 整形用 LLM) ─────────
  services.ollama = {
    enable = true;
    acceleration = null; # CPU only
    host = "0.0.0.0";
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 11434 ];
}

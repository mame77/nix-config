{ pkgs, lib, ... }:

{
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
}

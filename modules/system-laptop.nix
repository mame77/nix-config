{ pkgs, ... }:

{
  # ─── laptop-specific hardware ──────────────────────
  hardware.bluetooth.enable = true;
  services.upower.enable = true;

  # ─── xkb (login / fallback path; niri-side is in niri/config.kdl)
  services.xserver.xkb = {
    layout = "us";
    options = "ctrl:nocaps";
  };

  # ─── mame を bluetooth グループへ ──────────────────
  users.users.mame.extraGroups = [ "bluetooth" ];

  # ─── niri: scrollable-tiling Wayland compositor ────
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # ─── nix-ld: 動的リンクバイナリ (e.g. npm 版 supabase CLI) を通す ───
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [ stdenv.cc.cc glibc zlib ];

  # ─── greetd + tuigreet → niri-session ───────────────
  users.users.greeter = {
    isSystemUser = true;
    group = "greeter";
  };
  users.groups.greeter = { };

  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "greeter";
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
    };
  };

  # niri 配下で fcitx5 を autostart するため
  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  # ─── audio: PipeWire + WirePlumber ─────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  systemd.user.services.pipewire = {
    serviceConfig.Restart = "no";
  };
  systemd.user.services.wireplumber = {
    serviceConfig.Restart = "no";
  };
}

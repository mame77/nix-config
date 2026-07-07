{ config, pkgs, ... }:

let
  fcitx5Wrapper = config.i18n.inputMethod.fcitx5.package;
in

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
      command = "env XDG_DATA_DIRS=${pkgs.fcitx5-mozc}/share:${fcitx5Wrapper}/share:/run/current-system/sw/share:/etc/profiles/per-user/mame/share:/nix/var/nix/profiles/default/share LD_LIBRARY_PATH=${pkgs.fcitx5-mozc}/lib:${fcitx5Wrapper}/lib GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx INPUT_METHOD=fcitx SDL_IM_MODULE=fcitx ${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
    };
  };

  # ─── IME: fcitx5 + mozc (env vars / dbus / autostart 自動) ─
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = [ pkgs.fcitx5-mozc ];
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

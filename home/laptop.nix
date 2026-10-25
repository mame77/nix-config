{ inputs, lib, ... }:

{
  imports = [ ./desktop.nix ];

  home-manager.users.mame = { pkgs, ... }:
    {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    # Orca owns its profile and remote-environment state. Do not replace it
    # during Home Manager activation, or UI-added hosts/projects disappear.
    xdg.configFile."orca/Preferences" = {
      source = ../dotfiles/orca/Preferences;
      force = true;
    };

    home.file.".tmux.conf".source = lib.mkForce ../dotfiles/tmux/tmux-laptop.conf;

    # ─── desktop: niri / ghostty / btop の XDG 設定 ─
    xdg.configFile."niri/config.kdl".source = ../dotfiles/niri/config.kdl;
    xdg.configFile."niri/config.kdl".force = true;
    xdg.configFile."ghostty/config" = {
      source = ../dotfiles/ghostty/config;
      force = true;
    };
    xdg.configFile."niri/scripts".source    = ../dotfiles/niri/scripts;
    # The Nix package defaults to X11; use native Wayland IME for Fcitx.
    xdg.configFile."codex-desktop/electron-flags.conf".text = ''
      --ozone-platform=wayland
      --enable-wayland-ime=true
      --wayland-text-input-version=3
    '';
    # xdg.configFile.btop.source    = ../dotfiles/btop;

    # ─── noctalia ──────────────────────────────────
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };

    #
    # home.file."Pictures/Wallpapers/default.png".source =
    #   ../dotfiles/wallpapers/default.png;
    # xdg.configFile."noctalia/config.toml".source =
    #   config.lib.file.mkOutOfStoreSymlink ../dotfiles/noctalia/config.toml;
    #
    # ─── chrome keyd bind: Ctrl+J/K → Ctrl+Tab/Shift+Tab ──
    systemd.user.services.chrome-keyd-bind = {
      Unit = {
        Description = "Chrome-focused keyd remap for Ctrl+J/K → Ctrl+Tab";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.writeShellScript "chrome-keyd-bind" ''
          set -uo pipefail

          ACTIVE=false

          cleanup() {
              ${pkgs.keyd}/bin/keyd bind reset 2>/dev/null || true
          }
          trap cleanup EXIT INT TERM HUP

          while true; do
              APP_ID=$(${pkgs.niri}/bin/niri msg -j focused-window 2>/dev/null | \
                  ${pkgs.python3}/bin/python3 -c 'import json,sys; w=json.load(sys.stdin); print((w or {}).get("app_id",""))' 2>/dev/null || true)

              if [[ "$APP_ID" == "google-chrome" ]]; then
                  if [[ "$ACTIVE" != true ]]; then
                      ACTIVE=true
                      ${pkgs.keyd}/bin/keyd bind reset 'control.j=C-tab' 'control.k=C-S-tab' 2>/dev/null || true
                  fi
              else
                  if [[ "$ACTIVE" != false ]]; then
                      ACTIVE=false
                      ${pkgs.keyd}/bin/keyd bind reset 2>/dev/null || true
                  fi
              fi

              sleep 0.2
          done
        ''}";
        Restart = "on-failure";
        RestartSec = 2;
        Type = "simple";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}

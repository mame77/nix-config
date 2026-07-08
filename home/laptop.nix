{ inputs, ... }:

{
  home-manager.users.mame = { ... }: {
    imports = [
      inputs.noctalia.homeModules.default
      inputs.handy.homeManagerModules.default
    ];

    # ─── opencode TUI config (theme) ────────────────
    xdg.configFile."opencode/tui.json".text = ''
      {
        "$schema": "https://opencode.ai/tui.json",
        "theme": "system",
        "attention": {
          "enabled": true,
          "notifications": true,
          "sound": true,
          "volume": 0.4
        }
      }
    '';

    # ─── desktop: niri / ghostty / btop の XDG 設定 ─
    xdg.configFile."niri/config.kdl".source = ../dotfiles/niri/config.kdl;
    xdg.configFile."niri/scripts".source    = ../dotfiles/niri/scripts;
    xdg.configFile.ghostty.source = ../dotfiles/ghostty;
    xdg.configFile.btop.source    = ../dotfiles/btop;

    # ─── fcitx5 (mozc) ─────────────────────────────
    # niri の env {} ブロックは起動時にしか読まれないので、
    # ログインシェル側にも入れてターミナルや子プロセスに伝播させる。
    home.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      INPUT_METHOD = "fcitx";
      SDL_IM_MODULE = "fcitx";
      # xwayland-satellite が :0 で listen するので、Handy (Enigo) が
      # X11 ソケットへ繋げるよう DISPLAY を明示。
      DISPLAY = ":0";
    };

    # GUI アプリ (vivaldi 含む) は niri spawn 経由で起動されるとは限らない
    # (xdg-mime / noctalia / DBus 活性化など)。process は systemd --user
    # の子になるので、~/.config/environment.d/ を経由して全プロセスに伝播させる。
    # Vivaldi のラッパー (.vivaldi-wrapped) は IME env を含まないので必須。
    home.file.".config/environment.d/99-fcitx.conf".text = ''
      GTK_IM_MODULE=fcitx
      QT_IM_MODULE=fcitx
      XMODIFIERS=@im=fcitx
      INPUT_METHOD=fcitx
      SDL_IM_MODULE=fcitx
    '';

    # fcitx5/profile と conf/imselector.conf は home-manager 管理外。
    # 初回起動時に fcitx5 が ~/.config/fcitx5/ に作る素のファイルが
    # source of truth になり、GUI での変更が永続化する (keyconfig.conf と同じ挙動)。

    # ─── noctalia ──────────────────────────────────
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };

    # ─── handy (speech-to-text) ────────────────────
    # services.handy.enable = true;
    #
    # home.file."Pictures/Wallpapers/default.png".source =
    #   ../dotfiles/wallpapers/default.png;
    # xdg.configFile."noctalia/config.toml".source =
    #   config.lib.file.mkOutOfStoreSymlink ../dotfiles/noctalia/config.toml;
    #
    # ─── mimeapps ─────────────────────────────────
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/http" = "vivaldi-stable.desktop";
      "x-scheme-handler/https" = "vivaldi-stable.desktop";
      "x-scheme-handler/ftp" = "vivaldi-stable.desktop";
      "text/html" = "vivaldi-stable.desktop";
      "text/xml" = "vivaldi-stable.desktop";
      "application/xhtml+xml" = "vivaldi-stable.desktop";
      "application/xml" = "vivaldi-stable.desktop";
      "application/rss+xml" = "vivaldi-stable.desktop";
      "application/rdf+xml" = "vivaldi-stable.desktop";
      "image/gif" = "vivaldi-stable.desktop";
      "image/jpeg" = "vivaldi-stable.desktop";
      "image/png" = "vivaldi-stable.desktop";
      "x-scheme-handler/chrome" = "vivaldi-stable.desktop";
    };
  };
}

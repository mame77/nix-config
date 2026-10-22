{ ... }:

{
  home-manager.users.mame = { pkgs, ... }:
    let
      karukan-dict = pkgs.callPackage ../packages/karukan-dict.nix {};
      karukan-models = pkgs.callPackage ../packages/karukan-models.nix {};
    in {
    # ─── system theme: dark ────────────────────────
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

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

    xdg.configFile.ghostty.source = ../dotfiles/ghostty;
    xdg.configFile.foot.source = ../dotfiles/foot;

    # ─── fcitx5 ────────────────────────────────────
    # niri の env {} ブロックは起動時にしか読まれないので、
    # ログインシェル側にも入れてターミナルや子プロセスに伝播させる。
    home.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      INPUT_METHOD = "fcitx";
      SDL_IM_MODULE = "fcitx";
    };

    # GUI アプリ (chrome 含む) は niri spawn 経由で起動されるとは限らない
    # (xdg-mime / noctalia / DBus 活性化など)。process は systemd --user
    # の子になるので、~/.config/environment.d/ を経由して全プロセスに伝播させる。
    # Chrome のラッパー は IME env を含まないので必須。
    home.file.".config/environment.d/99-fcitx.conf".text = ''
      GTK_IM_MODULE=fcitx
      QT_IM_MODULE=fcitx
      XMODIFIERS=@im=fcitx
      INPUT_METHOD=fcitx
      SDL_IM_MODULE=fcitx
    '';

    # fcitx5 profile: keyboard-us + karukan を固定。
    # GUI で変更しても next home-manager switch で上書きされる。
    xdg.configFile."fcitx5/profile" = {
      force = true;
      text = ''
        [Groups/0]
        # Group Name
        Name=Default
        # Layout
        Default Layout=us
        # Default Input Method
        DefaultIM=karukan

        [Groups/0/Items/0]
        # Name
        Name=keyboard-us
        # Layout
        Layout=

        [Groups/0/Items/1]
        # Name
        Name=karukan
        # Layout
        Layout=

        [GroupOrder]
        0=Default
      '';
    };

    # ─── karukan (ニューラルかな漢字変換 IME) ──────────
    # システム辞書は Nix store 上の karukan-dict を参照。
    # 学習キャッシュ・ユーザー辞書は ~/.local/share/karukan-im/ に書き込まれる
    # (mutable なので Nix 管理外)。
    xdg.configFile."karukan-im/config.toml".text = ''
      [conversion]
      strategy = "adaptive"
      dict_path = "${karukan-dict}/share/karukan-im/dict.bin"
      model = "${karukan-models}/share/karukan-models/jinen-v1-small-Q5_K_M.gguf"
      light_model = "${karukan-models}/share/karukan-models/jinen-v1-xsmall-Q5_K_M.gguf"

      [learning]
      enabled = true
      max_entries = 10000
    '';

    # ─── mimeapps ─────────────────────────────────
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
      "x-scheme-handler/ftp" = "google-chrome.desktop";
      "text/html" = "google-chrome.desktop";
      "text/xml" = "google-chrome.desktop";
      "application/xhtml+xml" = "google-chrome.desktop";
      "application/xml" = "google-chrome.desktop";
      "application/rss+xml" = "google-chrome.desktop";
      "application/rdf+xml" = "google-chrome.desktop";
      "image/gif" = "google-chrome.desktop";
      "image/jpeg" = "google-chrome.desktop";
      "image/png" = "google-chrome.desktop";
      "x-scheme-handler/chrome" = "google-chrome.desktop";
    };

  };
}

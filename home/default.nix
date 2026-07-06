{ config, inputs, pkgs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.mame = { config, ... }: {
      home.username = "mame";
      home.homeDirectory = "/home/mame";
      home.stateVersion = "26.05";

      # ─── dev: tmux / nvim / opencode / bash ────────
      home.file.".tmux.conf".source = ../dotfiles/tmux/tmux.conf;
      xdg.configFile."nvim/init.lua".source = ../dotfiles/nvim/init.lua;
      xdg.configFile."nvim/lua".source      = ../dotfiles/nvim/lua;
      xdg.configFile."nvim/lsp".source      = ../dotfiles/nvim/lsp;
      xdg.configFile."opencode/tui.json".text = ''
        {
          "$schema": "https://opencode.ai/tui.json",
          "theme": "system"
        }
      '';
      programs.bash = {
        enable = true;
        initExtra =
          ''
            eval "$(${pkgs.direnv}/bin/direnv hook bash)"
          ''
          + builtins.readFile ../dotfiles/.bashrc;
      };

      # ─── desktop: niri / ghostty / btop の XDG 設定 ─
      xdg.configFile."niri/config.kdl".source = ../dotfiles/niri/config.kdl;
      xdg.configFile."niri/scripts".source    = ../dotfiles/niri/scripts;
      xdg.configFile.ghostty.source = ../dotfiles/ghostty;
      xdg.configFile.btop.source    = ../dotfiles/btop;

      # ─── fcitx5 ────────────────────────────────────
      # xdg.configFile."fcitx5/profile".text = ''
      #   [Groups/0]
      #   Name=Default
      #   Default Layout=us
      #   DefaultIM=mozc
      #
      #   [Groups/0/Items/0]
      #   Name=keyboard-us
      #   Layout=
      #
      #   [Groups/0/Items/1]
      #   Name=mozc
      #   Layout=
      #
      #   [GroupOrder]
      #   0=Default
      # '';
      # xdg.configFile."fcitx5/config".text = ''
      #   [Hotkey]
      #   TriggerKeys=
      #   EnumeratedHotkeys."0"=
      #   EnumeratedHotkeys."1"=
      # '';
      # xdg.configFile."fcitx5/conf/imselector.conf".text = ''
      #   [Addon/imselector]
      #   SwitchKey.0=Alt_L
      #   SwitchKey.1=Alt_R
      # '';

      # ─── noctalia ──────────────────────────────────
      imports = [
        inputs.noctalia.homeModules.default
        inputs.handy.homeManagerModules.default
      ];
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
      };

      # ─── handy (speech-to-text) ────────────────────
      services.handy.enable = true;

      home.file."Pictures/Wallpapers/default.png".source =
        ../dotfiles/wallpapers/default.png;
      xdg.configFile."noctalia/config.toml".source =
        config.lib.file.mkOutOfStoreSymlink ../dotfiles/noctalia/config.toml;

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
  };
}

{ ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.mame = { ... }: {
      home.username = "mame";
      home.homeDirectory = "/home/mame";
      home.stateVersion = "26.05";

      # ~/.tmux.conf (tmux reads this, NOT XDG)
      home.file.".tmux.conf".source = ../dotfiles/tmux/tmux.conf;

      # nvim: manage individual files as symlinks so `~/.config/nvim/`
      # itself stays writable — nvim writes nvim-pack-lock.json there.
      xdg.configFile."nvim/init.lua".source = ../dotfiles/nvim/init.lua;
      xdg.configFile."nvim/lua".source = ../dotfiles/nvim/lua;
      xdg.configFile."nvim/lsp".source = ../dotfiles/nvim/lsp;

      # niri: full config + scripts
      xdg.configFile."niri/config.kdl".source = ../dotfiles/niri/config.kdl;
      xdg.configFile."niri/scripts".source = ../dotfiles/niri/scripts;

      # other XDG apps
      xdg.configFile.ghostty.source = ../dotfiles/ghostty;
      xdg.configFile.btop.source = ../dotfiles/btop;

      # default browser
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

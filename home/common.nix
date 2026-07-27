{ pkgs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.mame = { ... }: {
      home.username = "mame";
      home.homeDirectory = "/home/mame";
      home.stateVersion = "26.05";
      home.sessionVariables.EDITOR = "nvim";

      # ─── dev: tmux / nvim / bash (fzf + ghq バインドは dotfiles/.bashrc 側) ─
      home.file.".tmux.conf".source = ../dotfiles/tmux/tmux.conf;
      xdg.configFile."herdr/config.toml".source = ../dotfiles/herdr/config.toml;
      xdg.configFile."nvim/init.lua".source = ../dotfiles/nvim/init.lua;
      xdg.configFile."nvim/lua".source      = ../dotfiles/nvim/lua;
      xdg.configFile."nvim/lsp".source      = ../dotfiles/nvim/lsp;
      programs.bash = {
        enable = true;
        initExtra =
          ''
            eval "$(${pkgs.mise}/bin/mise activate bash)"
            eval "$(${pkgs.direnv}/bin/direnv hook bash)"
          ''
          + builtins.readFile ../dotfiles/.bashrc;
      };
    };
  };
}

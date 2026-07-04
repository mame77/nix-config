{ ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.mame = { ... }: {
      home.username = "mame";
      home.homeDirectory = "/home/mame";
      home.stateVersion = "26.05";

      # symlink dotfiles into ~/.config (Nix-store backed, requires rebuild on change)
      xdg.configFile.nvim = {
        source = ../dotfiles/nvim;
        recursive = true;
      };
      xdg.configFile."tmux/tmux.conf".source = ../dotfiles/tmux/tmux.conf;
    };
  };
}

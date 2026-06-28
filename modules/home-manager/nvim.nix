{ pkgs, ... }:

{
  home.packages = [ pkgs.neovim ];

  xdg.configFile.nvim = {
    source = ../../dotfiles/nvim;
    recursive = true;
  };
}
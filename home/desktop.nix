{ ... }:

{
  # niri
  xdg.configFile."niri/config.kdl".source = ./dotfiles/niri/config.kdl;
  xdg.configFile."niri/scripts".source    = ./dotfiles/niri/scripts;

  # ghostty / btop
  xdg.configFile.ghostty.source = ./dotfiles/ghostty;
  xdg.configFile.btop.source    = ./dotfiles/btop;
}

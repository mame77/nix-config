{ ... }:

{
  programs.bash.enable = true;
  programs.bash.initExtra = builtins.readFile ../../dotfiles/bashrc/bashrc;
}
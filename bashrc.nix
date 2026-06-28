{ ... }:

{
  programs.bash.enable = true;
  programs.bash.interactiveShellInit = builtins.readFile ./bashrc/bashrc;
}
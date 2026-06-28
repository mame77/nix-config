{ config, ... }:

let
  user = "mame";
in
{
  system.activationScripts.nvimConfig = {
    text = ''
      mkdir -p /home/${user}/.config
      rm -rf /home/${user}/.config/nvim
      cp -r ${./nvim} /home/${user}/.config/nvim
      chown -R ${user}:users /home/${user}/.config/nvim
    '';
    deps = [];
  };
}
{ pkgs, ... }:

{
  # ssh
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
    };
  };

  # tailscale
  services.tailscale = {
    enable = true;
    openFirewall = true;
 #    authKeyFile = "/etc/tailscale/authkey";
  };
  environment.systemPackages = [ pkgs.tailscale ];

  # bash
  programs.bash = {
    enable = true;
    # nix-config の PS1 を NixOS デフォルトで上書きしない
    promptInit = "";
    interactiveShellInit =
      ''
        eval "$(${pkgs.direnv}/bin/direnv hook bash)"
      ''
      + builtins.readFile ../dotfiles/bashrc/bashrc;
  };

  # home-manager 時代の ~/.bashrc が PS1 を \w で上書きするのを防ぐ
  system.activationScripts.removeStaleHomeManagerBashrc.text = ''
    if [ -L /home/mame/.bashrc ] && readlink /home/mame/.bashrc | grep -q home-manager; then
      rm /home/mame/.bashrc
    fi
  '';
}

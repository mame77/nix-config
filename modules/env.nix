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
    authKeyFile = "/etc/tailscale/authkey";
  };
  environment.systemPackages = [ pkgs.tailscale ];

  # bash
  programs.bash = {
    enable = true;
    interactiveShellInit =
      ''
        eval "$(${pkgs.direnv}/bin/direnv hook bash)"
      ''
      + builtins.readFile ../dotfiles/bashrc/bashrc;
  };
}

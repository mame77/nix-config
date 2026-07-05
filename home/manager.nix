{ ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.mame = { ... }: {
      imports = [
        ./common.nix
        ./dev.nix
        ./desktop.nix
        ./mimeapps.nix
      ];

      home.username = "mame";
      home.homeDirectory = "/home/mame";
      home.stateVersion = "26.05";
    };
  };

  # Remove a stale home-manager-managed ~/.bashrc symlink so the
  # programs.bash session sources /etc/bashrc (and the dotfiles/.bashrc
  # appended via home/dev.nix) instead of the previous HM-managed file.
  system.activationScripts.removeStaleHomeManagerBashrc.text = ''
    if [ -L /home/mame/.bashrc ] && readlink /home/mame/.bashrc | grep -q home-manager; then
      rm /home/mame/.bashrc
    fi
  '';
}

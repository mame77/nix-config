{ inputs, ... }:

{
  # NixOS-level module: augments home-manager.users.mame.
  # `inputs` is provided via the flake's specialArgs.
  home-manager.users.mame = { config, ... }: {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };

    home.file."Pictures/Wallpapers/default.png".source =
      ../../home/dotfiles/wallpapers/default.png;

    # Two-way sync: HM-managed symlink to the live file in the repo.
    # `config.lib.file.mkOutOfStoreSymlink` is the official HM API for
    # symlinking outside the Nix store (so the GUI can write to it).
    xdg.configFile."noctalia/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink ../../home/dotfiles/noctalia/config.toml;
  };
}

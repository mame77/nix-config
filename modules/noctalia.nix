{ inputs, ... }:

{
  home-manager.users.mame = { ... }: {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };

    home.file."Pictures/Wallpapers/default.png".source =
      ../dotfiles/wallpapers/default.png;

    # Symlink the TOML config to the dotfile in the repo for two-way sync.
    # We can't use programs.noctalia.settings because Nix would copy the
    # git-tracked file into /nix/store (read-only), breaking GUI writes.
    home.activation.linkNoctaliaConfig = ''
      mkdir -p "$HOME/.config/noctalia"
      rm -f "$HOME/.config/noctalia/config.toml"
      ln -s /home/mame/nix-config/dotfiles/noctalia/config.toml \
        "$HOME/.config/noctalia/config.toml"
    '';
  };
}

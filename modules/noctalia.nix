{ inputs, ... }:

{
  home-manager.users.mame = { ... }: {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;

      settings = {
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };
        wallpaper = {
          enabled = true;
          "default.path" = "/home/mame/Pictures/Wallpapers/default.png";
        };
      };
    };

    home.file."Pictures/Wallpapers/default.png".source =
      ../dotfiles/wallpapers/default.png;
  };
}

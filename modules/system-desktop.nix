{ pkgs, ... }:

let
  fcitx5-karukan = pkgs.callPackage ../packages/fcitx5-karukan.nix {};
in
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = [ fcitx5-karukan ];
  };

  fonts.packages = with pkgs; [ udev-gothic-nf noto-fonts-cjk-sans ];
  programs.dconf.enable = true;
  services.dbus.enable = true;
  services.gnome.at-spi2-core.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  systemd.user.services.pipewire.serviceConfig.Restart = "no";
  systemd.user.services.wireplumber.serviceConfig.Restart = "no";
}

{ ... }:

{
  # time language
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  # user
  users.users.mame = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "bluetooth" ];
    initialPassword = "mame";
  };

  # bluetooth
  hardware.bluetooth.enable = true;

  # docker
  virtualisation.docker.enable = true;

  # upower (required by noctalia battery widget)
  services.upower.enable = true;
}

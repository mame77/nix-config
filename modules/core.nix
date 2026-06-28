{ ... }:

{
  # time language
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  # user
  users.users.mame = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    initialPassword = "mame";
  };

  # docker
  virtualisation.docker.enable = true;
}

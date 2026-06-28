{ ... }:

{
  users.users.mame = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "mame";
  };
}
{ ... }:

{
  virtualisation.docker.enable = true;

  users.users.mame.extraGroups = [ "docker" ];
}
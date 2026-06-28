{ pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = "/etc/tailscale/authkey";
  };

  environment.systemPackages = [ pkgs.tailscale ];
}
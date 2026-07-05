{ pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
  environment.systemPackages = [ pkgs.tailscale ];
}

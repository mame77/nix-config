{ config, pkgs, ... }:

{
  # ─── bootloader ─────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ─── network / locale ───────────────────────────────
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  # ─── autologin ──────────────────────────────────────
  services.getty.autologinUser = "mame";

  # ─── user ───────────────────────────────────────────
  users.users.mame = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "input" "networkmanager" ];
    initialPassword = "mame";
  };

  # ─── docker ─────────────────────────────────────────
  virtualisation.docker.enable = true;

  # ─── openssh ────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
    };
  };

  # ─── tailscale ──────────────────────────────────────
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # ─── base system packages ───────────────────────────
  environment.systemPackages = let
    chromium-wrapped = pkgs.writeShellScriptBin "chromium" ''
      exec ${pkgs.chromium}/bin/chromium --user-data-dir="$HOME/.config/chromium-${config.networking.hostName}" "$@"
    '';
  in with pkgs; [
    curl
    tailscale
    sshfs
    chromium-wrapped
    xwayland-satellite
    fastfetch
  ];

  system.stateVersion = "26.05";
}

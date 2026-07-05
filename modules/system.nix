{ pkgs, ... }:

{
  # ─── bootloader ─────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ─── network / locale ───────────────────────────────
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  # ─── user ───────────────────────────────────────────
  users.users.mame = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
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
  environment.systemPackages = with pkgs; [
    curl
    tailscale
  ];

  system.stateVersion = "26.05";
}

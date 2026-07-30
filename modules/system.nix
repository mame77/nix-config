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
    bw-sudo = pkgs.writeShellScriptBin "bw-sudo" ''
      set -euo pipefail

      token="''${BWS_ACCESS_TOKEN:-}"
      token_file="''${BWS_ACCESS_TOKEN_FILE:-$HOME/.config/bws/sudo-token}"
      if [ -z "$token" ] && [ -r "$token_file" ]; then
        token="$(<"$token_file")"
      fi

      if [ -z "$token" ]; then
        printf '%s\n' "BWS_ACCESS_TOKEN is not set and the token file is unavailable." >&2
        exit 1
      fi

      if [ "$#" -eq 0 ]; then
        printf '%s\n' "Usage: bw-sudo COMMAND [ARGUMENTS...]" >&2
        exit 2
      fi

      secret_id="$(BWS_ACCESS_TOKEN="$token" ${pkgs.bws}/bin/bws secret list --output json |
        ${pkgs.jq}/bin/jq -r '[.[] | select(.key == "sudo")] | if length == 1 then .[0].id else empty end')"

      if [ -z "$secret_id" ]; then
        printf '%s\n' "Exactly one accessible Bitwarden Secrets Manager secret named sudo is required." >&2
        exit 1
      fi

      BWS_ACCESS_TOKEN="$token" ${pkgs.bws}/bin/bws secret get "$secret_id" --output json |
        ${pkgs.jq}/bin/jq -r 'if type == "array" then .[0].value else .value end' |
        ${config.security.wrapperDir}/sudo -S -k -- "$@"
    '';
  in with pkgs; [
    curl
    tailscale
    sshfs
    chromium-wrapped
    bw-sudo
    bws
    xwayland-satellite
    fastfetch
  ];

  system.stateVersion = "26.05";
}

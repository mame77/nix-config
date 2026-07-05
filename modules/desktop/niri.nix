{ pkgs, ... }:

{
  # niri — scrollable-tiling Wayland compositor
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # greetd (display/login manager) + tuigreet (TUI greeter) → niri-session
  users.users.greeter = {
    isSystemUser = true;
    group = "greeter";
  };
  users.groups.greeter = { };

  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "greeter";
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
    };
  };

  # moved here from modules/fcitx5.nix — needed for fcitx5 to autostart under niri
  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  # audio: PipeWire + WirePlumber (PulseAudio compat + ALSA + 32bit ALSA)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
    pulse.enable = true;
  };

  # real-time scheduling for audio threads (avoids xruns)
  security.rtkit.enable = true;

  # NOTE: pipewire/wireplumber restart policy explicitly disabled.
  # NixOS pipewire package's upstream unit sets `Restart=on-failure` by
  # default, which combined with the pipewire-0.lockfile produces
  # 88+ restart loops (lockfile held by previous instance) and a
  # start-limit-hit, leaving audio broken after reboot. We override to
  # `Restart=no` so the system can never enter that loop. If audio
  # breaks for any reason, the user can manually restart via
  # `systemctl --user restart pipewire wireplumber`.
  systemd.user.services.pipewire = {
    serviceConfig.Restart = "no";
  };
  systemd.user.services.wireplumber = {
    serviceConfig.Restart = "no";
  };
}

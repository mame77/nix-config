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

  # audio: PipeWire + WirePlumber (PulseAudio compat enabled)
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    pulse.enable = true;
  };

  # niri config + scripts are now managed by home-manager (see modules/home.nix).
}

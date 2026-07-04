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

  # deliver niri config to /etc/niri/config.kdl
  environment.etc."niri/config.kdl".source = ../dotfiles/niri/config.kdl;

  # niri only reads $XDG_CONFIG_HOME/niri/config.kdl, so symlink it
  # into the user's home. Only creates the symlink if nothing exists there yet,
  # so a user-local override is preserved across rebuilds.
  system.activationScripts.niriUserConfig = {
    text = ''
      mkdir -p /home/mame/.config/niri
      if [ ! -e /home/mame/.config/niri/config.kdl ]; then
        ln -s /etc/niri/config.kdl /home/mame/.config/niri/config.kdl
        chown -h mame:users /home/mame/.config/niri/config.kdl
      fi
      chown mame:users /home/mame/.config/niri
    '';
    deps = [ "users" ];
  };
}

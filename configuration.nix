{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  # time
  time.timeZone = "Asia/Tokyo";
  # language
  i18n.defaultLocale = "en_US.UTF-8";

  # server sleep
  services.logind = {
    settings = {
      Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchDocked = "ignore";
        HandleLidSwitchExternalPower = "ignore";
      };
    };
  };
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # services.xserver.enable = true;


  

  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # services.printing.enable = true;

  # services.pulseaudio.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # services.libinput.enable = true;

  users.users.mame = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "mame";
    packages = with pkgs; [
      tree
    ];
  };

  # programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    neovim
    tmux
    curl
    tailscale
  ];

  services.tailscale.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
    };
  };

  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  # dont tach
  system.stateVersion = "26.05"; # Did you read the comment?

}


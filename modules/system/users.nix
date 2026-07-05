{ ... }:

{
  users.users.mame = {
    isNormalUser = true;
    # `bluetooth` group is added by profiles/laptop.nix on hosts that need it.
    extraGroups = [ "wheel" "docker" ];
    initialPassword = "mame";
  };
}

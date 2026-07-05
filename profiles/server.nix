{ ... }:

{
  imports = [
    ../modules/services/logind-server.nix
    ../modules/packages/dev.nix
    ../modules/packages/server.nix
  ];
}

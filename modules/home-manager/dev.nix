{ pkgs, lib, config, ... }:

{
  programs.go.enable = true;

  home.activation.removeStaleMise = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -f "${config.xdg.configHome}/mise/config.toml"
  '';

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.shellAliases = {
    python = "python3.12";
  };

  home.packages = with pkgs; [
    nodejs
    bun
    pnpm
    python312
    python312Packages.pip
    gcc
    gnumake
    pkg-config
    ripgrep
    fd
    jq
  ];
}
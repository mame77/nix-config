{ inputs, pkgs, ... }:

let
  androidSdk = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "35" ];
    buildToolsVersions = [ "34.0.0" "35.0.0" ];
    platformToolsVersion = "35.0.2";
    includeEmulator = true;
    emulatorVersion = "35.1.19";
    includeSystemImages = true;
    systemImageTypes = [ "google_apis" ];
    abiVersions = [ "x86_64" ];
  };
  sdkRoot = "${androidSdk.androidsdk}/libexec/android-sdk";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/system-laptop.nix
    ../../modules/dev.nix
    ../../modules/tool.nix
    ../../home/common.nix
    ../../home/laptop.nix
    inputs.openwhispr.nixosModules.default
  ];

  networking.hostName = "laptop";

  users.users.mame.packages = with pkgs; [
    androidSdk.androidsdk
    android-studio
    jdk21_headless
  ];

  home-manager.users.mame.home.sessionVariables = {
    ANDROID_HOME = sdkRoot;
    ANDROID_SDK_ROOT = sdkRoot;
  };

  programs.openwhispr = {
    enable = true;
    users = [ "mame" ];
  };
}

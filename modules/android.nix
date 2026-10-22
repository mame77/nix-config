{ pkgs, ... }:

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
  # Keep the SDK and emulator image identical on the laptop and development host.
  users.users.mame = {
    extraGroups = [ "adbusers" "kvm" ];
    packages = with pkgs; [
      androidSdk.androidsdk
      android-studio
      jdk21_headless
      scrcpy
    ];
  };

  # USB devices need explicit permissions outside an active local seat as well.
  users.groups.adbusers = { };
  # systemd already supplies active-seat uaccess rules. Add group access for
  # the ADB USB interface so remote/SSH sessions work without a local login.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{ID_USB_INTERFACES}=="*:ff4201:*", GROUP="adbusers", MODE="0660", TAG+="uaccess"
  '';

  home-manager.users.mame.home.sessionVariables = {
    ANDROID_HOME = sdkRoot;
    ANDROID_SDK_ROOT = sdkRoot;
  };
}

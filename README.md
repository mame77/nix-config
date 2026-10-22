# NixOS development environment

## Hosts

| | laptop | server |
|---|---|---|
| Desktop | niri + Noctalia | Persistent Xfce on Xvfb (`:99`, 1920×1080) |
| GUI applications | Chrome, Ghostty, Orca, OpenCode, Obsidian, Bitwarden | Same |
| Japanese input | Fcitx 5 + Karukan | Same |
| Android | SDK 35, Google APIs x86_64 image, Android Studio, JDK 21, scrcpy | Same |
| Development | Shared `modules/dev.nix` and `home/common.nix` | Same |

The server has no connected monitor. Its virtual desktop persists when the
viewer disconnects. Orca and the viewer use the **same** display and user D-Bus
session. This does not add official Codex desktop Computer Use support to Linux;
each AI tool still needs its own supported browser/accessibility integration.

## Apply

From this repository on the machine being configured:

```sh
sudo nixos-rebuild switch --flake .#server
# On the laptop, use .#laptop instead.
```

Keep existing uncommitted changes in a server checkout when updating it. A clean
deployment checkout can be used separately; there is no need to reset the main
checkout or its `flake.lock`.

## View the server desktop from the laptop

```sh
nix run .#server-desktop
# With a different SSH alias:
nix run .#server-desktop -- server-raw
```

After applying the laptop configuration, `server-desktop` is also available as
a regular command. The client opens an SSH tunnel and TigerVNC. Closing the
viewer closes its tunnel, but leaves server applications running. Local port
15900 must be free. VNC listens only on loopback; no firewall port is opened.
SSH provides authentication and encryption. Chrome/Bitwarden sign-ins and Android
USB-debugging authorization must be completed on the server's own profiles.

The server services are `orca-xvfb`, `server-desktop`, `server-desktop-vnc`, and
`orca-serve`. Logs are available with `journalctl -u SERVICE`. The SSH account
`mame` shares display `:99` and the user bus at `/run/user/1000/bus`.

## Android on the server

On the server, create an AVD once and run it headlessly:

```sh
avdmanager create avd --name fitswipe --package 'system-images;android-35;google_apis;x86_64' --device pixel
emulator -avd fitswipe -no-window -no-audio -no-boot-anim -gpu swiftshader_indirect
```

The SDK is managed in the Nix store; the writable AVD and its data live under
`~/.android/avd`. Change SDK components in `modules/android.nix`, rather than
installing into the read-only SDK with Android Studio. `mame` belongs to `kvm`
and `adbusers`; existing login sessions need a new login to receive new groups.

From the laptop, view and control that emulator (or a USB-connected Android):

```sh
nix run .#server-android
# If multiple devices are connected:
nix run .#server-android -- server --serial emulator-5554
```

The client forwards local ports 15038 (remote ADB) and 27183 (scrcpy video and
control) over SSH. These ports must be free on the laptop; remote port 27183 must
also be available. The ADB service stays on server loopback. Both real USB phones
and emulators appear in `adb devices` on the server. No server desktop is needed
for this Android-only client.

Avoid simultaneous manual and AI input on the same screen/device.

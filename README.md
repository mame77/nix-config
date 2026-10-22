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

When Home Manager adopts an existing server settings file, it preserves the old
file next to it with the suffix `.before-server-desktop`.

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

TigerVNC `x0vncserver` shares the existing display and transfers clipboard text
with its UTF-8 Extended Clipboard support, preserving Japanese when copying
between the laptop and server. Only the explicit clipboard is synchronized;
selecting text alone does not replace it. Recopy text after reconnecting if an
older connection already converted Japanese characters to question marks.

In the remote desktop, tap **Left Alt** to select Japanese (Karukan) and
**Right Alt** to select English. The former Shift+Space toggle is disabled.
The remote IME state is shared across windows, including browser sign-in windows.
The desktop and Orca services export `GTK_PATH` and `GTK_IM_MODULE_FILE` so
terminals and Orca's Electron input fields can load Fcitx's GTK input module
from the system's generated module cache. Configuration switches preserve
the running desktop; environment changes apply to a new desktop session, and
existing applications must be reopened with the updated environment.

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

For AI interaction inside Android, the server installs `$android-emulator-use`.
It reads screenshots/UI Automator hierarchies and sends taps, swipes and key
events through ADB with an explicit device serial. Android controls are not
desktop AT-SPI elements inside the scrcpy mirror. Example: "Use
$android-emulator-use to inspect FitSwipe, open the preset screen and return
home without changing its records."

## AI desktop control through Orca

On the server, Chrome starts with `--force-renderer-accessibility` so Orca can
read its address bar and page controls. An already-running browser must be
reopened for this launch flag to take effect. The desktop-control skill uses
complete address-field replacement and checks the URL before navigation.

The pinned Orca Linux provider includes a keyboard patch: named keys use
`xdotool` keysyms instead of passing GDK keysyms as AT-SPI hardware keycodes;
hotkey letters are normalized so `CmdOrCtrl+A` does not add an implicit Shift.
Synthetic named keys and shortcuts clear held modifiers during delivery.

The Orca package supplies a dedicated Python runtime, AT-SPI/GTK introspection
paths, and X11 screenshot/input helpers. The `orca-serve` service shares display
`:99` and the user D-Bus session with the visible Xfce desktop.

The server installs the `orca-computer-use` skill under `~/.agents/skills` so
Codex can discover the CLI workflow. In a server chat, ask for desktop work with
`$orca-computer-use`, for example: "Use $orca-computer-use to inspect the app's
home screen." If an existing chat has not discovered the skill, start a new chat.

The development app's CLI is `orca-ide` (also available as `orca`). Read its
version-matched guide with `orca-ide skills get computer-use`, then use
`orca-ide computer capabilities --json` and follow that guide. Screenshots and
saved files are on the server. Keep private application content scoped to the
requested task and coordinate manual/AI input on the shared desktop.

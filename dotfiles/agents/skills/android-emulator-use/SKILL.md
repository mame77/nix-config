---
name: android-emulator-use
description: Inspect and operate Android emulators on this development server using ADB screenshots, UI hierarchies, taps, swipes, and keyboard input. Use for interacting with or checking FitSwipe from the Google repository on the running emulator.
---

# Android emulator on the development server

Run ADB on the development server. A laptop chat must run the commands through
its server connection. Inspect `adb devices -l` and explicitly select the target
with `-s SERIAL` for every operation. The development emulator is usually
`emulator-5554` (AVD `dev-api35`). FitSwipe's package is `dev.local.fitlogsolo`,
with launcher activity `.MainActivity`; its repository is
`/home/mame/ghq/github.com/mame77/Google`.

The scrcpy window mirrors Android pixels. Android controls belong to the guest
OS and are not exposed as desktop AT-SPI controls. Use ADB for Android UI, and
Orca's desktop skill for native desktop apps and browsers.

## Observe, act, observe

Capture the current screen and its UI hierarchy on the server:

```sh
adb -s SERIAL exec-out screencap -p > /tmp/android-screen.png
adb -s SERIAL shell uiautomator dump /sdcard/ai-window.xml
adb -s SERIAL exec-out cat /sdcard/ai-window.xml > /tmp/android-window.xml
```

View the screenshot and inspect relevant XML nodes (`text`, `content-desc`,
`bounds`, `enabled`, `clickable`, `scrollable`). Use the current node's bounds
or observed screenshot to choose touch coordinates. A label can be nested in a
clickable parent. Coordinates use the full Android screen's pixels, not the
scaled scrcpy window. Do not reuse coordinates across keyboard, sheet,
orientation, or navigation changes.

```sh
adb -s SERIAL shell input tap X Y
adb -s SERIAL shell input swipe X1 Y1 X2 Y2 DURATION_MS
adb -s SERIAL shell input keyevent KEYCODE_BACK
```

Refresh the hierarchy/screenshot after each action and confirm the actual
screen change. A successful shell command alone does not prove the UI changed.
For ASCII text, focus an observed editable field before using
`adb -s SERIAL shell input text ASCII_TEXT`; handle shell quoting explicitly.
Android's `input text` does not reliably enter Japanese; use a verified IME
workflow for that rather than claiming success.

Inspect the app's save behavior before exploratory edits: some FitSwipe preset
fields save immediately, while the add-preset name is only a draft until
creation. Stay within the user's requested changes. Do not clear app data,
delete records, start/post a workout, or change permissions merely to check UI
control. Leave a verification session on its original screen when practical.

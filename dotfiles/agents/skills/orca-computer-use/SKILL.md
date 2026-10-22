---
name: orca-computer-use
description: See and operate applications on this development server's Linux desktop through Orca. Use for reading windows, taking screenshots, clicking, typing, scrolling, or dragging in server desktop apps and browser windows.
---

# Server desktop through Orca

The server's persistent X11 desktop is display `:99`. It is the same desktop the
user sees through `server-desktop`/TigerVNC. Run commands on this server; a laptop
SSH chat must execute them through its server connection.

Use `/etc/profiles/per-user/mame/bin/orca-ide`. This is the Orca development app's
CLI, not the GNOME Orca screen reader.

Before operating a window, load the installed version's instructions:

```sh
/etc/profiles/per-user/mame/bin/orca-ide skills get computer-use
```

Follow that guide for status, capabilities, app discovery, snapshots, actions,
and error handling. Prefer JSON responses. Select windows from fresh observed
state. Screenshot paths returned by the CLI belong to this server; view those
images before choosing coordinates.

## Chrome navigation

The server's Chrome launcher enables `--force-renderer-accessibility`. If a
snapshot contains only a window/frame, the existing Chrome process may predate
that configuration. Report this and reopen Chrome through its configured
launcher while preserving the user's session; do not keep typing into a field
you cannot identify. A running Chrome process ignores new launch flags.

For navigation, first get fresh Chrome state with `--restore-window`. Find the
address/search entry in `treeText`, focus it, and use `computer set-value` to
replace its entire contents. Inspect the returned state: confirm the complete
requested URL and the focused input before pressing Return. Then get fresh
state and verify the resulting URL, title, and page content.

Do not assume `type-text` replaces existing contents. If direct value writes are
unsupported, focus the observed address field, select all with the documented
hotkey, and use `paste-text` once. Confirm the exact value before Return. Stop
and report unexpected concatenation instead of appending the URL repeatedly.

## Android emulator

For controls inside the Android emulator, use the installed
`~/.agents/skills/android-emulator-use/SKILL.md` workflow. The scrcpy mirror
does not expose Android controls through the desktop AT-SPI tree; ADB supplies
the guest screenshot, hierarchy, touch input, and key events.

Use the user's requested apps and actions. Installing this skill does not
authorize sending messages, submitting forms, purchases, or account changes.
Respect existing authorization and tool permissions. If access is blocked,
report the blocker rather than bypassing it.

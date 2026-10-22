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

Use the user's requested apps and actions. Installing this skill does not
authorize sending messages, submitting forms, purchases, or account changes.
Respect existing authorization and tool permissions. If access is blocked,
report the blocker rather than bypassing it.

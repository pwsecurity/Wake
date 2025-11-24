# Wake

## What this app does
Wake is a single-file macOS utility that temporarily disables the built‑in lid-close sleep guard. Launching it keeps your Mac awake with the lid shut (useful when driving an external monitor, running long jobs, or keeping servers online). The script also presents a playful retro console UI so users can see when sleep is disabled/enabled.

Key behaviors:
- Calls `pmset disablesleep 1` on launch and automatically reverts to `pmset disablesleep 0` when you exit.
- Displays diagnostic/status panes so you always know whether sleep is currently disabled.
- Captures exit signals (⌃C, window close, etc.) to ensure normal sleep behavior is restored even if the session ends unexpectedly.

## Requirements
- macOS with the built-in `pmset` command (macOS 10.10+ should work).
- Admin rights: `pmset disablesleep` requires root; the script attempts passwordless sudo (`sudo -n`). If your account isn’t already authorized, run it once from a Terminal session to enter your password.
- Terminal app (default Apple Terminal recommended; the script auto-minimizes the window after launch for a cleaner desktop).

## Setup
1. Download or clone the repo to `/Applications`, `~/Scripts`, or any preferred folder.
2. Grant execute permission once:
   ```bash
   chmod +x /Users/you/path/to/Wake/wake
   ```
3. (Optional) Drag the file into the Dock or Finder sidebar for quick access.

## Using Wake
1. **Launch**: Double-click the Wake script (or run `./wake` from Terminal). The terminal window animates a boot sequence and reports that sleep is disabled.
2. **Close the lid**: Your Mac now keeps running with the lid shut.
3. **Restore normal sleep**:
   - Press any key while the script window is focused **or**
   - Quit the window (⌘W / close button) **or**
   - Press ⌃C in Terminal.
   Any exit path re-enables the default sleep policy before the window closes.

## Safety characteristics
- **Auto-reset on exit**: Sleep is always re-enabled thanks to the `trap finish EXIT` handler.
- **Signal-aware**: Handles HUP/INT/QUIT/TERM, so even abrupt exits restore the default state.
- **Visual confirmation**: The status panel clearly shows whether sleep is off or on; wait for the green “Sleep enabled” message before shutting down the window.

## Tips & troubleshooting
- *Need sudo password?* Run once from a Terminal session; when prompted, enter your password. Future double-clicks may succeed without prompts if your sudo timestamp remains valid.
- *Want it to start minimized?* Use Apple Terminal—the script already minimizes the window via AppleScript. Other terminals can be used but will stay visible.
- *Unexpected wake behavior?* Manually run `sudo pmset disablesleep 0` to restore defaults, then relaunch the script.
- *External displays failing to wake?* Ensure the lid is completely closed and that power remains connected for MacBooks that throttle without AC.

## Limitations & warnings
- Not a full clamshell-mode manager—only toggles the sleep guard. macOS still enforces other thermal or battery throttles.
- Use in well-ventilated setups; keeping a Mac awake while closed can increase heat.
- Tested only on Apple Silicon and Intel Macs running macOS Ventura/Sonoma. Older versions should work but aren’t officially verified.

## Contributing / customization ideas
- Adjust colors, ASCII art, or copy inside `draw_banner`, `draw_panels`, and `animate_boot`.
- Swap AppleScript minimization behavior if you prefer a different terminal emulator.
- Extend diagnostics to read actual `pmset -g` values or battery stats.

---
Have feedback or want new features? Open an issue or PR so others understand the behavior before running the script.


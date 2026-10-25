# Connection Center TV: auto-mute WING Matrix 3

The lobby Connection Center TV is driven by the Dell PC in the sound booth. On Sundays, Task Scheduler switches between the PowerPoint slideshow and NDI Studio Monitor. `wing-matrix-mute.ps1` unmutes Matrix 3 on the Behringer WING while NDI is showing and mutes it again when PowerPoint comes back.

It sends one OSC message (`/mtx/3/mute`, 0 = unmuted, 1 = muted) to the WING on UDP port 2223.

## Setup

1. Copy `wing-matrix-mute.ps1` to `C:\Scripts\` on the Dell.
2. Open it and set `$WingIP` to the WING's full IP address (it ends in .49).

## Task Scheduler action

- Program/script: `powershell.exe`
- Arguments: `-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Scripts\wing-matrix-mute.ps1" -Mute 0`

Use `-Mute 0` to unmute and `-Mute 1` to mute. Put the action after the taskkill and before the app starts, so the brief PowerShell window can't take focus from the fullscreen app.

| Time | Actions in order |
|---|---|
| 8:15 | `-Mute 1` (safety), start PowerPoint |
| 9:01 | kill PowerPoint, `-Mute 0`, start NDI |
| 10:05 | kill NDI, `-Mute 1`, start PowerPoint |
| 10:31 | kill PowerPoint, `-Mute 0`, start NDI |
| 11:35 | kill NDI, `-Mute 1`, start PowerPoint |

## Testing

Run the Arguments line from a Command Prompt and watch Matrix 3 on the console. If nothing happens:

- Ping the WING's IP to make sure the Dell is on the same network.
- Check the WING firmware version.

Tested and working at the console on 2026-10-25.

# Automatic shutdown

A weekly task shuts the PC down after services. It shows a popup with a Cancel button first, so anyone still using the PC can keep it on.

## Shutdown task

Create Task (not Basic Task) with:

- **Trigger:** Weekly, Sunday, at the shutdown time (for example 12:30 PM).
- **General tab:** check "Run with highest privileges". "Run only when user is logged on" is fine, and is needed for the popup to show.
- **Settings tab:** leave "Run task as soon as possible after a scheduled start is missed" unchecked, or the PC could shut down whenever it's turned on later in the week.
- **Action:**

Program/script:

```
powershell.exe
```

Arguments:

```
-NoProfile -WindowStyle Hidden -Command "if ((New-Object -ComObject WScript.Shell).Popup('This PC will shut down in 2 minutes. Click Cancel to keep it on.',120,'Shutdown',4097) -ne 2) { Stop-Computer -Force }"
```

The popup stays on top of other windows. Cancel keeps the PC on. OK, or no click within 2 minutes, shuts it down. Test it once with the PowerPoint slideshow running to make sure the popup shows over it.

## Simpler alternative (no popup)

If the popup gives trouble, use this action instead. It shows Windows' own 2-minute warning.

Program/script:

```
shutdown.exe
```

Arguments:

```
/s /f /t 120 /c "Church PC shutting down in 2 minutes. Use the Cancel Shutdown shortcut to stop it."
```

To give it a cancel button, make a desktop shortcut: right-click the desktop, New > Shortcut, enter the location below, and name it "Cancel Shutdown".

```
shutdown.exe /a
```

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
| 9:57 | kill NDI, `-Mute 1`, start PowerPoint |
| 10:31 | kill PowerPoint, `-Mute 0`, start NDI |
| 11:27 | kill NDI, `-Mute 1`, start PowerPoint |

## Testing

Run the Arguments line from a Command Prompt and watch Matrix 3 on the console. If nothing happens:

- Ping the WING's IP to make sure the Dell is on the same network.
- Check the WING firmware version. The address `/mtx/3/mute` follows the WING's OSC naming but hasn't been confirmed at the console yet.

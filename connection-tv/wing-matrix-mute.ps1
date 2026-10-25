# Mutes or unmutes a matrix on the Behringer WING by sending one OSC message over UDP.
# Usage:  powershell -File wing-matrix-mute.ps1 -Mute 1   (mute)
#         powershell -File wing-matrix-mute.ps1 -Mute 0   (unmute)
param(
    [string]$WingIP = "192.168.1.49",   # change to the WING's full IP address
    [int]$Matrix = 3,
    [ValidateSet(0, 1)][int]$Mute = 1
)

# OSC strings end with a null byte and are padded with nulls to a multiple of 4 bytes.
function OscString([string]$s) {
    $bytes = [Text.Encoding]::ASCII.GetBytes($s)
    $len = [Math]::Ceiling(($bytes.Length + 1) / 4) * 4
    $out = New-Object byte[] $len
    [Array]::Copy($bytes, $out, $bytes.Length)
    return ,$out
}

$address = OscString "/mtx/$Matrix/mute"
$typeTag = OscString ",i"
$value = [BitConverter]::GetBytes([int32]$Mute)
[Array]::Reverse($value)   # OSC integers are big-endian

[byte[]]$packet = $address + $typeTag + $value

$udp = New-Object System.Net.Sockets.UdpClient
try {
    [void]$udp.Send($packet, $packet.Length, $WingIP, 2223)
} finally {
    $udp.Close()
}

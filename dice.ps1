# DisplayDeck MOD: Dice (https://github.com/willailora/DiceDisplayDeckMOD). MIT License.
# Rolls the dice set on the tile (1D100, 2D20, 3D6+2 ...) and prints one JSON object:
#   { "text": "<total>", "sub": "<notation and each roll>", "error": null }
# No network, no files written.
$ErrorActionPreference = 'Stop'

$lang = $env:DISPLAYDECK_LANG
if ([string]::IsNullOrEmpty($lang)) { $lang = 'en' }
$ja = ($lang.Split('-')[0].ToLowerInvariant() -eq 'ja')

function Out-Json($obj) {
    $json = ConvertTo-Json -InputObject $obj -Compress
    $bytes = (New-Object System.Text.UTF8Encoding($false)).GetBytes($json)
    $stdout = [Console]::OpenStandardOutput()
    $stdout.Write($bytes, 0, $bytes.Length)
    $stdout.Flush()
}
function Fail($jaMsg, $enMsg) {
    if ($ja) { $m = $jaMsg } else { $m = $enMsg }
    Out-Json @{ error = $m }
    exit 0
}
# Any unexpected error still answers with JSON.
trap { Fail 'ダイスを振れませんでした' 'Could not roll the dice.' }

# Setting: "dice" (empty = 1D100). Full-width letters and digits are accepted (Ｄ, ２ ...).
$spec = $env:DISPLAYDECK_SETTING_DICE
if ([string]::IsNullOrWhiteSpace($spec)) { $spec = '1D100' }
$spec = $spec.Normalize([Text.NormalizationForm]::FormKC).Trim()
$m = [regex]::Match($spec, '^([0-9]{0,3})\s*[dD]\s*([0-9]{1,6})\s*(?:([+\-])\s*([0-9]{1,6}))?\z')
if (-not $m.Success) {
    Fail ('「' + $spec + '」は読めません。1D100・2D20・3D6+2 のように書いてください') ('Cannot read "' + $spec + '". Write it like 1D100, 2D20 or 3D6+2.')
}
$count = 1
if ($m.Groups[1].Value.Length -gt 0) { $count = [int]$m.Groups[1].Value }
$faces = [int]$m.Groups[2].Value
$bonus = 0
if ($m.Groups[3].Success) {
    $bonus = [int]$m.Groups[4].Value
    if ($m.Groups[3].Value -eq '-') { $bonus = -$bonus }
}
if ($count -lt 1 -or $count -gt 100) { Fail 'ダイスの数は 1〜100 個にしてください' 'Use 1 to 100 dice.' }
if ($faces -lt 2 -or $faces -gt 100000) { Fail '面の数は 2〜100000 にしてください' 'Use 2 to 100000 faces.' }

# Unbiased roll from the OS cryptographic random generator (rejection sampling).
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$buf = New-Object byte[] 4
$range = [long]4294967296
$limit = $range - ($range % $faces)
function Roll-One {
    while ($true) {
        $rng.GetBytes($buf)
        $v = [long][BitConverter]::ToUInt32($buf, 0)
        if ($v -lt $limit) { return [int]($v % $faces) + 1 }
    }
}

$rolls = New-Object System.Collections.Generic.List[int]
$total = [long]0
for ($i = 0; $i -lt $count; $i++) { $r = Roll-One; $rolls.Add($r); $total += $r }
$total += $bonus
$rng.Dispose()

$notation = [string]$count + 'D' + [string]$faces
if ($bonus -gt 0) { $notation += '+' + $bonus } elseif ($bonus -lt 0) { $notation += [string]$bonus }

# Each roll is listed for up to 6 dice (more would not fit on a tile); otherwise just the notation.
if (($count -eq 1 -and $bonus -eq 0) -or $count -gt 6) {
    $sub = $notation
} else {
    $sub = $notation + ': ' + ($rolls -join '+')
    if ($bonus -gt 0) { $sub += ' (+' + $bonus + ')' } elseif ($bonus -lt 0) { $sub += ' (' + $bonus + ')' }
}

Out-Json @{ text = [string]$total; sub = $sub; error = $null }

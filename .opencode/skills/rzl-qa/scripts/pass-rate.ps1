# Compute the RZL functionality pass rate from docs/qa/test-cases.md
#
# Usage:
#   powershell -File .opencode/skills/rzl-qa/scripts/pass-rate.ps1
#   powershell -File .opencode/skills/rzl-qa/scripts/pass-rate.ps1 -Detailed
#   powershell -File .opencode/skills/rzl-qa/scripts/pass-rate.ps1 -MinRate 90
#
# Exits 0 when the pass rate meets MinRate, 1 otherwise.
# Deliberately ASCII-only output so it renders correctly in Windows PowerShell 5.1.

[CmdletBinding()]
param(
    [string]$Path = 'docs/qa/test-cases.md',
    [double]$MinRate = 90,
    [switch]$Detailed
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $Path)) {
    Write-Error "Test matrix not found: $Path"
    exit 1
}

# Status markers from docs/qa/test-cases.md, referenced by code point so this script
# does not depend on its own file encoding.
$markPass    = [string][char]0x2705   # white heavy check mark
$markFail    = [string][char]0x274C   # cross mark
$markBlocked = [string][char]0xD83D + [string][char]0xDEAB  # no entry sign
$markNa      = [string][char]0x23ED   # next track

$rows = Get-Content -Path $Path -Encoding UTF8 | Where-Object { $_ -match '^\|\s*TC-\d+' }

if ($rows.Count -eq 0) {
    Write-Error "No test-case rows found in $Path (expected table rows starting with '| TC-')."
    exit 1
}

$pass = 0; $fail = 0; $blocked = 0; $na = 0; $notRun = 0

foreach ($row in $rows) {
    if     ($row.Contains($markPass))    { $pass++ }
    elseif ($row.Contains($markFail))    { $fail++ }
    elseif ($row.Contains($markBlocked)) { $blocked++ }
    elseif ($row.Contains($markNa))      { $na++ }
    else                                 { $notRun++ }
}

$total    = $rows.Count
$executed = $total - $notRun - $na
$denom    = $total - $na
$rate     = if ($denom -gt 0) { [math]::Round(($pass / $denom) * 100, 1) } else { 0 }
$required = [math]::Ceiling($denom * ($MinRate / 100.0))
$remaining = [math]::Max(0, $required - $pass)

$colour = if ($rate -ge $MinRate) { 'Green' } else { 'Red' }

Write-Host ''
Write-Host 'RZL - Functionality Test Summary' -ForegroundColor Cyan
Write-Host ('=' * 40)
Write-Host ("Total test cases   : {0}" -f $total)
Write-Host ("Executed           : {0}" -f $executed)
Write-Host ("Passed             : {0}" -f $pass) -ForegroundColor Green
Write-Host ("Failed             : {0}" -f $fail) -ForegroundColor Red
Write-Host ("Blocked            : {0}" -f $blocked) -ForegroundColor Yellow
Write-Host ("Not applicable     : {0}" -f $na)
Write-Host ("Not run            : {0}" -f $notRun)
Write-Host ('-' * 40)
Write-Host ("Pass rate          : {0}%  (target {1}%)" -f $rate, $MinRate) -ForegroundColor $colour
Write-Host ("Passes required    : {0} of {1}" -f $required, $denom)

if ($remaining -gt 0) {
    Write-Host ("Still needed       : {0}" -f $remaining) -ForegroundColor Yellow
} elseif ($fail -eq 0 -and $notRun -eq 0 -and $blocked -eq 0) {
    Write-Host 'Gate status        : PASSED' -ForegroundColor Green
} else {
    Write-Host 'Gate status        : threshold met, but failures or unexecuted rows remain' -ForegroundColor Yellow
}
Write-Host ''

if ($Detailed) {
    Write-Host 'Rows not yet executed:' -ForegroundColor Cyan
    $rows | Where-Object {
        -not $_.Contains($markPass) -and -not $_.Contains($markFail) -and
        -not $_.Contains($markBlocked) -and -not $_.Contains($markNa)
    } | ForEach-Object {
        $cells = ($_ -split '\|') | ForEach-Object { $_.Trim() }
        Write-Host ("  {0}  {1,-6}  {2}" -f $cells[1], $cells[2], $cells[3])
    }
    Write-Host ''
}

if ($rate -lt $MinRate) { exit 1 } else { exit 0 }

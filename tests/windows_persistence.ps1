$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
$qa = Join-Path $root 'build/windows-qa'
New-Item -ItemType Directory -Force $qa | Out-Null
function Invoke-GodotCheck([string]$Executable, [string[]]$Arguments, [string]$Name, [string]$Marker) {
    $stdout = Join-Path $qa "$Name.out.log"
    $stderr = Join-Path $qa "$Name.err.log"
    $process = Start-Process -FilePath $Executable -ArgumentList $Arguments -PassThru -NoNewWindow -RedirectStandardOutput $stdout -RedirectStandardError $stderr
    if (-not $process.WaitForExit(120000)) {
        $process.Kill()
        throw "$Name timed out"
    }
    $process.WaitForExit()
    $text = ((Get-Content $stdout -Raw -ErrorAction SilentlyContinue), (Get-Content $stderr -Raw -ErrorAction SilentlyContinue)) -join "`n"
    Write-Output $text
    if ($process.ExitCode -ne 0 -or $text -match 'SCRIPT ERROR:|(^|\s)ERROR:|Parse Error:' -or ($Marker -and $text -notmatch $Marker)) {
        throw "$Name failed: exit $($process.ExitCode)"
    }
}
$editor = Join-Path $env:RUNNER_TEMP 'godot-windows/Godot_v4.7.2-stable_win64.exe'
Invoke-GodotCheck $editor @('--headless', '--editor', '--path', '.', '--import') 'import' ''
Invoke-GodotCheck $editor @('--headless', '--path', '.', '--script', 'res://tests/persistence.gd') 'editor-persistence' 'PERSISTENCE_OK:'
# Read the expected version from checked-out source, independently of the PCK.
$versionMatch = Select-String -Path (Join-Path $root 'project.godot') -Pattern '^config/version="([^"]+)"$' | Select-Object -First 1
if (-not $versionMatch) { throw 'Source project has no version identity' }
$expectedVersion = $versionMatch.Matches[0].Groups[1].Value
$exe = Join-Path $root 'build/package/Game2.exe'
if (-not (Test-Path $exe) -or -not (Test-Path (Join-Path $root 'build/package/Game2.pck'))) { throw 'Missing exported game package' }
Push-Location (Join-Path $root 'build/package')
try {
    Invoke-GodotCheck $exe @('--rendering-method', 'gl_compatibility', '--audio-driver', 'Dummy', '--', '--qa-persistence', '--expect-export', "--expect-version=$expectedVersion") 'exported-exe-persistence' 'PERSISTENCE_OK:'
} finally { Pop-Location }
if (-not (Test-Path (Join-Path $qa 'recovered-investigation.png'))) { throw 'Missing actual Windows EXE render capture' }
$hashes = Get-FileHash $exe, (Join-Path $root 'build/package/Game2.pck') -Algorithm SHA256
$hashes | Select-Object Path, Hash | ConvertTo-Json | Set-Content (Join-Path $qa 'tested-package-sha256.json')
Write-Output 'WINDOWS_PERSISTENCE_OK: Windows editor and actual exported EXE passed the filesystem and scene recovery suite'

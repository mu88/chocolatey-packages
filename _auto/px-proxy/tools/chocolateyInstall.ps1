$ErrorActionPreference = 'Stop'

$packageName = 'px-proxy'
$url64 = 'https://github.com/genotrance/px/releases/download/v0.10.3/px-v0.10.3-windows-amd64.zip'
$checksum64 = '444c591d5847c653870f55d2cf14c773e9a750cf10df4d0beda1a488850ba63d'
$checksumType64 = 'sha256'

$packageParameters = Get-PackageParameters
$installSystemWide = $false
$enableStartup = $false

if ($packageParameters.ContainsKey('SystemWide')) {
    $installSystemWide = $true
}

if ($packageParameters.ContainsKey('Startup')) {
    $enableStartup = $true
}

$toolsLocation = Get-ToolsLocation
$installDir = if ($installSystemWide) {
    Join-Path $env:ProgramFiles 'PxProxy'
} else {
    Join-Path $toolsLocation 'PxProxy'
}

if (Test-Path $installDir) {
    Remove-Item -Path $installDir -Recurse -Force
}

Install-ChocolateyZipPackage `
    -PackageName $packageName `
    -UnzipLocation $installDir `
    -Url64bit $url64 `
    -Checksum64 $checksum64 `
    -ChecksumType64 $checksumType64

$pxExe = Get-ChildItem -Path $installDir -Filter 'px.exe' -Recurse -File |
    Select-Object -First 1 -ExpandProperty FullName

if (-not $pxExe) {
    throw "px.exe was not found after extracting '$url64' to '$installDir'."
}

Uninstall-BinFile -Name 'px' -ErrorAction SilentlyContinue
Install-BinFile -Name 'px' -Path $pxExe

if ($enableStartup) {
    # Only modify startup task when explicitly requested via package parameter.
    $mainTaskName = 'PxProxy'
    $mainTask = Get-ScheduledTask -TaskName $mainTaskName -ErrorAction SilentlyContinue
    if ($mainTask) {
        Unregister-ScheduledTask -TaskName $mainTaskName -Confirm:$false -ErrorAction SilentlyContinue
    }

    $startupTrigger = New-ScheduledTaskTrigger -AtStartup
    $startupPrincipal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount

    $taskAction = New-ScheduledTaskAction -Execute $pxExe
    Register-ScheduledTask -TaskName $mainTaskName -Action $taskAction -Trigger $startupTrigger -Principal $startupPrincipal -Force | Out-Null
}

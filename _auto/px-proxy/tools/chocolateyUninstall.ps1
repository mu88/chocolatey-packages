$ErrorActionPreference = 'Stop'

$toolsInstallDir = Join-Path (Get-ToolsLocation) 'PxProxy'
$programFilesInstallDir = Join-Path $env:ProgramFiles 'PxProxy'
$chocoInstallDir = if ($env:ChocolateyInstall) { $env:ChocolateyInstall } else { Join-Path $env:ProgramData 'chocolatey' }
$shimDir = Join-Path $chocoInstallDir 'bin'

# Remove the shim entry created by Install-BinFile
Uninstall-BinFile -Name 'px'

foreach ($shimFileName in @('px.exe', 'px.exe.ignore')) {
    $shimPath = Join-Path $shimDir $shimFileName
    if (Test-Path $shimPath) {
        Remove-Item -Path $shimPath -Force -ErrorAction SilentlyContinue
    }
}

if (Test-Path $toolsInstallDir) {
    Remove-Item -Path $toolsInstallDir -Recurse -Force
}

if (Test-Path $programFilesInstallDir) {
    Remove-Item -Path $programFilesInstallDir -Recurse -Force
}

$mainTaskName = 'PxProxy'
$mainTask = Get-ScheduledTask -TaskName $mainTaskName -ErrorAction SilentlyContinue
if ($mainTask) {
    Unregister-ScheduledTask -TaskName $mainTaskName -Confirm:$false -ErrorAction SilentlyContinue
}

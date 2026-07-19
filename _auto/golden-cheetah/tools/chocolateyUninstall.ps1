$ErrorActionPreference = 'Stop'

$packageName = 'golden-cheetah'
$uninstallerPath = $null

$uninstallRegistryPaths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Golden Cheetah',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Golden Cheetah'
)

foreach ($registryPath in $uninstallRegistryPaths) {
    if (-not (Test-Path $registryPath)) {
        continue
    }

    $uninstallEntry = Get-ItemProperty -Path $registryPath
    if ($uninstallEntry.UninstallString) {
        $uninstallerPath = $uninstallEntry.UninstallString.Trim('"')
        break
    }
}

if (-not $uninstallerPath) {
    $fallbackUninstallerPath = Join-Path $env:ProgramFiles 'Golden Cheetah\uninst.exe'
    if (Test-Path $fallbackUninstallerPath) {
        $uninstallerPath = $fallbackUninstallerPath
    }
}

if (-not $uninstallerPath -or -not (Test-Path $uninstallerPath)) {
    throw "Could not find Golden Cheetah uninstaller path for package '$packageName'."
}

$uninstallArgs = @{
    PackageName = $packageName
    FileType = 'exe'
    SilentArgs = '/S'
    File = $uninstallerPath
}

Uninstall-ChocolateyPackage @uninstallArgs

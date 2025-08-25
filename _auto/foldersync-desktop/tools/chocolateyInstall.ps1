$ErrorActionPreference = 'Stop'

$packageName  = 'foldersync-desktop'
$url64        = 'https://github.com/tacitdynamics/foldersync-desktop-production/releases/download/2.6.0/foldersync-desktop-2.6.0.x64.msix'
$toolsDir     = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$fileName     = Split-Path -Path $url64 -Leaf
$fileFullPath = Join-Path $toolsDir $fileName
$checksum     = 'ba091b0683be74ff77cd2dd3e439e33c0a95f14934ddcb9cf99349e4b9bef264'
$checksumType = 'sha256'

# Download installer package and verify checksum
Get-ChocolateyWebFile -PackageName $packageName -FileFullPath $fileFullPath -Url64bit $url64 -Checksum64 $checksum -ChecksumType64 $checksumType

# Install the package for all users (that's why we use DISM instead of Add-AppxPackage)
DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$fileFullPath /SkipLicense

# On Windows 11 24H2, Microsoft broke all *-AppxPackage commands. As a temporary workaround, we use the GAC to install some required assemblies.
Add-Type -AssemblyName "System.EnterpriseServices"
$publish = [System.EnterpriseServices.Internal.Publish]::new()
@(
    'System.Numerics.Vectors.dll',
    'System.Runtime.CompilerServices.Unsafe.dll',
    'System.Security.Principal.Windows.dll',
    'System.Memory.dll'
) | ForEach-Object {
    $dllPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\$_"
    $publish.GacInstall($dllPath)
}

# Disable package auto updates as otherwise Chocolatey might get confused
$packageFamilyName = (Get-AppxPackage -AllUsers | Where-Object { $_.Name -eq 'FoldersyncDesktop' }).PackageFamilyName
Remove-AppxPackageAutoUpdateSettings -PackageFamilyName $packageFamilyName -AllUsers

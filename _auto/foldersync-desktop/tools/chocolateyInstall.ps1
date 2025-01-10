$ErrorActionPreference = 'Stop'

$packageName  = 'foldersync-desktop'
$url64        = 'https://github.com/tacitdynamics/foldersync-desktop-production/releases/download/2.0.3/foldersync-desktop-2.0.3.x64.msix'
$toolsDir     = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$fileName     = Split-Path -Path $url64 -Leaf
$fileFullPath = Join-Path $toolsDir $fileName
$checksum     = '1382B247EFB2DCB964500B23804067B94F3BC4CD617557448013A54F0154CDDC'
$checksumType = 'SHA256'

# Download installer package and verify checksum
Get-ChocolateyWebFile -PackageName $packageName -FileFullPath $fileFullPath -Url64bit $url64 -Checksum64 $checksum -ChecksumType64 $checksumType

# Install the package for all users (that's why we use DISM instead of Add-AppxPackage)
DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$fileFullPath /SkipLicense

# Disable package auto updates as otherwise Chocolatey might get confused
$packageFamilyName = (Get-AppxPackage -AllUsers | Where-Object { $_.Name -eq 'FoldersyncDesktop' }).PackageFamilyName
Remove-AppxPackageAutoUpdateSettings -PackageFamilyName $packageFamilyName -AllUsers

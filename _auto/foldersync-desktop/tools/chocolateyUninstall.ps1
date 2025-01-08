$ErrorActionPreference = 'Stop'

$packageFullName = (Get-AppxPackage -AllUsers | Where-Object { $_.Name -eq 'FoldersyncDesktop' }).PackageFullName
Remove-AppxPackage -Package $packageFullName

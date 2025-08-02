﻿$ErrorActionPreference = 'Stop'

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

$packageFullName = (Get-AppxPackage -AllUsers | Where-Object { $_.Name -eq 'FoldersyncDesktop' }).PackageFullName
Remove-AppxPackage -Package $packageFullName -AllUsers

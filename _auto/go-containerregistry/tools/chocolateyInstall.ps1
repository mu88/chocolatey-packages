$ErrorActionPreference = 'Stop'

$packageName    = 'go-containerregistry'
$url64          = 'https://github.com/google/go-containerregistry/releases/download/v0.21.7/go-containerregistry_Windows_x86_64.tar.gz'
$checksum64     = '88a1693e8d49298f9c44c81fbca55efea8f5ab1be3c760534cfb8d932ca88baa'
$checksumType64 = 'sha256'

$installDir = Join-Path (Get-ToolsLocation) 'GoContainerRegistry'

if (Test-Path $installDir) {
    Remove-Item -Path $installDir -Recurse -Force
}

# First pass: .tar.gz -> .tar
Install-ChocolateyZipPackage `
    -PackageName    $packageName `
    -UnzipLocation  $installDir `
    -Url64bit       $url64 `
    -Checksum64     $checksum64 `
    -ChecksumType64 $checksumType64

# Second pass: .tar -> binaries
$tarFile = Get-ChildItem -Path $installDir -Filter '*.tar' -File | Select-Object -First 1
if (-not $tarFile) {
    throw "No .tar file found in '$installDir' after extracting '$url64'."
}
Get-ChocolateyUnzip -FileFullPath $tarFile.FullName -Destination $installDir
Remove-Item -Path $tarFile.FullName -Force

foreach ($binaryName in @('crane', 'gcrane', 'krane')) {
    $exePath = Get-ChildItem -Path $installDir -Filter "$binaryName.exe" -Recurse -File |
        Select-Object -First 1 -ExpandProperty FullName
    if (-not $exePath) {
        throw "$binaryName.exe was not found after extracting '$url64' to '$installDir'."
    }
    Uninstall-BinFile -Name $binaryName -ErrorAction SilentlyContinue
    Install-BinFile -Name $binaryName -Path $exePath
}

$ErrorActionPreference = 'Stop'

$packageName    = 'go-containerregistry'
$url64          = 'https://github.com/google/go-containerregistry/releases/download/v0.22.1/go-containerregistry_Windows_x86_64.tar.gz'
$checksum64     = '0e073ea8192c3b8442ec8aaf44d53c1050a09084669fae3a6ceb0f2026cf8b21'
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

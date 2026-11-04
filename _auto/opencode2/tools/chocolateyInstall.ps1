$ErrorActionPreference = 'Stop'

$packageName = 'opencode2'
$url64 = 'https://github.com/anomalyco/opencode/releases/download/v2.2.5/opencode-windows-x64.zip'
$checksum64 = '2f3bfd6b3527c60c2a882557b20ddc9ba6bdff4b5a8fe61c853da8fcfb3076e8'
$checksumType64 = 'sha256'

$architecture = $env:PROCESSOR_ARCHITEW6432
if (-not $architecture) {
    $architecture = $env:PROCESSOR_ARCHITECTURE
}
if ($architecture -ne 'AMD64') {
    throw 'This package supports Windows x64 only.'
}

$installDir = Join-Path (Get-ToolsLocation) 'OpenCode2'
$executablePath = Join-Path $installDir 'opencode.exe'

Install-ChocolateyZipPackage -PackageName $packageName -UnzipLocation $installDir -Url64bit $url64 -Checksum64 $checksum64 -ChecksumType64 $checksumType64

if (-not (Test-Path -LiteralPath $executablePath -PathType Leaf)) {
    throw "opencode.exe was not found in the release archive '$url64'."
}

Install-BinFile -Name 'opencode2' -Path $executablePath

$ErrorActionPreference = 'Stop'

$packageName = 'opencode2'
$url64 = 'https://github.com/anomalyco/opencode/releases/download/v2.3.0/opencode-windows-x64.zip'
$checksum64 = '2e14eee53f4abad803d55fdc472c1b12dc3802d687ae204f81e7908bd2ab1895'
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
$addOpenCodeShim = (Get-PackageParameters)['AddOpenCodeShim'] -eq $true

Install-ChocolateyZipPackage -PackageName $packageName -UnzipLocation $installDir -Url64bit $url64 -Checksum64 $checksum64 -ChecksumType64 $checksumType64

if (-not (Test-Path -LiteralPath $executablePath -PathType Leaf)) {
    throw "opencode.exe was not found in the release archive '$url64'."
}

Install-BinFile -Name 'opencode2' -Path $executablePath
if ($addOpenCodeShim) {
    Install-BinFile -Name 'opencode' -Path $executablePath
    New-Item -ItemType File -Path (Join-Path $installDir 'opencode-shim.installed') -Force | Out-Null
}

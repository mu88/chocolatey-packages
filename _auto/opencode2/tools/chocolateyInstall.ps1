$ErrorActionPreference = 'Stop'

$packageName = 'opencode2'
$url64 = 'https://github.com/anomalyco/opencode/releases/download/v2.3.2/opencode-windows-x64.zip'
$checksum64 = '8ad59f1992a0594d8bd72b5ed3be1f5bfffcd9d1756853eec7e5d3141c25be1f'
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

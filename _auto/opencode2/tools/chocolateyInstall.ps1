$ErrorActionPreference = 'Stop'

$packageName = 'opencode2'
$url64 = 'https://github.com/anomalyco/opencode/releases/download/v2.2.7/opencode-windows-x64.zip'
$checksum64 = '91398e0e2c2bc72f6c93dbdae426a0710884ed3277a08558200753c7a995daa8'
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

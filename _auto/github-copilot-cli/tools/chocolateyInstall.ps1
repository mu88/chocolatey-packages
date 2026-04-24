$ErrorActionPreference = "Stop"

$packageName   = 'github-copilot-cli'
$toolsDir      = Get-ToolsLocation
$installDir    = Join-Path $toolsDir 'GitHubCopilotCLI'
$url64         = 'https://github.com/github/copilot-cli/releases/download/v1.0.35/copilot-win32-x64.zip'
$checksum64    = '9a2b2078cf933b5a822cf664cbf378ee779dd8bd0ef7c07d7f1b1a8dd9956d98'
$checksumType64 = 'sha256'

$packageArgs = @{
  packageName    = $packageName
  unzipLocation  = $installDir
  url64bit       = $url64
  checksum64     = $checksum64
  checksumType64 = $checksumType64
}

if (Test-Path $installDir) {
  Remove-Item $installDir -Recurse -Force
}

Install-ChocolateyZipPackage @packageArgs

$copilotExe = Get-ChildItem -Path $installDir -Filter 'copilot.exe' -Recurse -File |
  Select-Object -First 1 -ExpandProperty FullName

if (-not $copilotExe) {
  throw "copilot.exe was not found after extracting '$url64' to '$installDir'."
}

Uninstall-BinFile -Name 'copilot' -ErrorAction SilentlyContinue
Install-BinFile -Name 'copilot' -Path $copilotExe

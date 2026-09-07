$ErrorActionPreference = "Stop"

$packageName   = 'github-copilot-cli'
$toolsDir      = Get-ToolsLocation
$installDir    = Join-Path $toolsDir 'GitHubCopilotCLI'
$url64         = 'https://github.com/github/copilot-cli/releases/download/v1.0.83/copilot-win32-x64.zip'
$checksum64    = '0e07221a275fdf7e61619c53566e3a421fd646d74d8e9ca491dbbff221f22945'
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

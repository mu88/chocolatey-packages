$ErrorActionPreference = "Stop"

$packageName = 'github-copilot-cli'
$url64       = 'https://github.com/github/copilot-cli/releases/download/v1.0.2/copilot-x64.msi'

$packageArgs = @{
  packageName    = $packageName
  fileType       = 'msi'
  url64bit       = $url64
  silentArgs     = "/qn /norestart"
  validExitCodes = @(0)
  softwareName   = 'GitHub Copilot CLI*'
  checksum64     = '1f24d0f5a1f3b7c4856e2b0b3cf6370cd19b5ef51c63b37e4c71eb70806face3'
  checksumType64 = 'sha256'
}

Install-ChocolateyPackage @packageArgs

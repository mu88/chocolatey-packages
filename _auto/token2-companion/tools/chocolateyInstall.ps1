$ErrorActionPreference = "Stop"

$packageName  = 'token2-companion'
$url          = 'https://www.token2.com/soft/Token2_Companion_App-2.0.2_R6.zip'
$toolsDir     = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$installDir   = Join-Path $env:ProgramFiles 'Token2 Companion App'
$checksum     = 'D3797E6E57BC76C4D4C1915D868CA72F03C31BB27F43BE1F09511AA92F1C2FEA'
$checksumType = 'sha256'

# Download installer package and verify checksum
Install-ChocolateyZipPackage `
  -PackageName $packageName `
  -Url $url `
  -UnzipLocation $toolsDir `
  -Checksum $checksum `
  -ChecksumType $checksumType

# Locate extracted application folder (e.g. "Token2 Companion App 2.0.2 R6")
$appFolder = Get-ChildItem -Path $toolsDir -Directory |
  Where-Object { $_.Name -like 'Token2 Companion App*' } |
  Select-Object -First 1

if (-not $appFolder) {
  throw "Application folder not found after extraction."
}

# Create installation directory
New-Item -ItemType Directory -Force -Path $installDir | Out-Null

# Copy full application folder contents to Program Files
Copy-Item `
  -Path (Join-Path $appFolder.FullName '*') `
  -Destination $installDir `
  -Recurse `
  -Force

# Locate executable inside installation directory
$exePath = Get-ChildItem -Path $installDir -Recurse -Filter "Token2 Companion App*.exe" |
  Select-Object -First 1

if (-not $exePath) {
  throw "Executable not found after copy."
}

# Create Start Menu shortcut
Install-ChocolateyShortcut `
  -ShortcutFilePath "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Token2 Companion App.lnk" `
  -TargetPath $exePath.FullName

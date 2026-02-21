$ErrorActionPreference = 'Stop'

$installDir = Join-Path $env:ProgramFiles 'Token2 Companion App'

# Remove installation directory
Remove-Item $installDir -Recurse -Force -ErrorAction SilentlyContinue

# Remove Start Menu shortcut
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Token2 Companion App.lnk" -Force -ErrorAction SilentlyContinue

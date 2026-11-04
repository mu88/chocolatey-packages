$ErrorActionPreference = 'Stop'

Uninstall-BinFile -Name 'opencode2'

$installDir = Join-Path (Get-ToolsLocation) 'OpenCode2'
$executablePath = Join-Path $installDir 'opencode.exe'
if (Test-Path -LiteralPath $executablePath -PathType Leaf) {
    Remove-Item -LiteralPath $executablePath
}
if ((Test-Path -LiteralPath $installDir -PathType Container) -and -not (Get-ChildItem -LiteralPath $installDir -Force)) {
    Remove-Item -LiteralPath $installDir
}

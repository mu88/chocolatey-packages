$ErrorActionPreference = "Stop"

$toolsDir = Get-ToolsLocation
$installDir = Join-Path $toolsDir 'GitHubCopilotCLI'

Uninstall-BinFile -Name 'copilot' -ErrorAction SilentlyContinue

if (Test-Path $installDir) {
  Remove-Item $installDir -Recurse -Force
}

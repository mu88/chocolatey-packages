$ErrorActionPreference = 'Stop'

$installDir = Join-Path (Get-ToolsLocation) 'GoContainerRegistry'

foreach ($binaryName in @('crane', 'gcrane', 'krane')) {
    Uninstall-BinFile -Name $binaryName -ErrorAction SilentlyContinue
}

if (Test-Path $installDir) {
    Remove-Item -Path $installDir -Recurse -Force
}

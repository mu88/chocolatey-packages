<#
.SYNOPSIS
    Regenerates the Chocolatey version badges in README.md from the current _auto/*/*.nuspec files.

.DESCRIPTION
    The version badges in README.md are derived state: they must always reflect whatever version is
    currently in each package's .nuspec. Previously, every update.ps1 patched its own README badge via
    au_SearchReplace directly. When several packages were updated in the same CI run, their README
    patches touched neighboring table rows, which regularly caused merge/rebase conflicts.
    Deriving the badges from the nuspecs in one place - after all package changes have been applied -
    removes README.md from the set of files that can conflict between packages entirely.

.PARAMETER RepositoryRoot
    Path to the repository root, i.e. the directory containing README.md and _auto/. Defaults to the
    parent directory of this script (build/..), which is correct when the script keeps its location.

.EXAMPLE
    ./build/Sync-ReadmeVersion.ps1
    Updates README.md in place using the nuspec files found under _auto/ relative to the repository root.

.EXAMPLE
    ./build/Sync-ReadmeVersion.ps1 -RepositoryRoot 'C:\checkout\chocolatey-packages'
    Updates README.md in an explicitly specified checkout, e.g. when invoked from a different working directory.

.OUTPUTS
    None. Rewrites README.md in place.

.NOTES
    Emits a warning (does not throw) for any package whose id has no matching badge row in README.md,
    so a newly added package without a README entry does not break the whole sync run.
#>
[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$readmePath = Join-Path $RepositoryRoot 'README.md'
$readmeContent = Get-Content -LiteralPath $readmePath -Raw

$nuspecFiles = Get-ChildItem -Path (Join-Path $RepositoryRoot '_auto') -Filter '*.nuspec' -Recurse

foreach ($nuspecFile in $nuspecFiles) {
    [xml]$nuspec = Get-Content -LiteralPath $nuspecFile.FullName -Raw
    $packageId = $nuspec.package.metadata.id
    $packageVersion = $nuspec.package.metadata.version

    $pattern = "(?i)(\*\*$([regex]::Escape($packageId))\*\*.*?Chocolatey-)[\d.]+(-green)"
    $replacement = "`${1}$packageVersion`${2}"

    # Compare match presence, not before/after content: content is legitimately unchanged whenever
    # the badge is already in sync, which must not be flagged as "badge not found".
    if (-not [regex]::IsMatch($readmeContent, $pattern)) {
        Write-Warning "No README badge found for package '$packageId' - skipping."
        continue
    }

    $readmeContent = $readmeContent -replace $pattern, $replacement
}

Set-Content -LiteralPath $readmePath -Value $readmeContent -NoNewline

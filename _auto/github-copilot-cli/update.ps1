Param (
    [string]$GitHubToken
)

import-module Chocolatey-AU

function global:au_GetLatest {
    $LatestRelease = Invoke-RestMethod -UseBasicParsing -Uri "https://api.github.com/repos/github/copilot-cli/releases/latest" -Authentication Bearer -Token ($GitHubToken | ConvertTo-SecureString -AsPlainText)
    $LatestVersion = $LatestRelease.tag_name

    return @{
        URL64   = $LatestRelease.assets | Where-Object { $_.name.endsWith("-x64.msi") } | Select-Object -ExpandProperty browser_download_url
        Version = if ($LatestVersion.StartsWith("v")) {$LatestVersion.Substring(1) } else { $LatestVersion }
    }
}

function global:au_SearchReplace {
    $year = (Get-Date).Year

    @{
        '.\github-copilot-cli.nuspec' = @{
            "(?i)(<version>).*?(</version>)"     = "`${1}$($Latest.Version)`${2}"
            "(?i)(<copyright>).*?(</copyright>)" = "`${1}© Copyright $year GitHub, Inc.`${2}"
        }

        '.\tools\chocolateyInstall.ps1' = @{
            "(?i)(^\s*(\$)url64\s*=\s*)('.*')"        = "`$1'$($Latest.URL64)'"
            "(?i)(^\s*(\$)checksum\s*=\s*)('.*')"     = "`$1'$($Latest.Checksum64)'"
            "(?i)(^\s*(\$)checksumType\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType64)'"
        }
    }
}

update -ChecksumFor 64

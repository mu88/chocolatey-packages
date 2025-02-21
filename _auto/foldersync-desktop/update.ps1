import-module Chocolatey-AU

function global:au_GetLatest {
    $LatestRelease = Invoke-RestMethod -UseBasicParsing -Uri "https://api.github.com/repos/tacitdynamics/foldersync-desktop-production/releases/latest"
    $LatestVersion = $LatestRelease.tag_name

    return @{
        URL64   = $LatestRelease.assets | Where-Object { $_.name.endsWith(".x64.msix") } | Select-Object -ExpandProperty browser_download_url
        Version = $LatestVersion
    }
}

function global:au_SearchReplace {
    @{
        '.\tools\chocolateyInstall.ps1' = @{
            "(?i)(^\s*(\$)url64\s*=\s*)('.*')"        = "`$1'$($Latest.URL64)'"
            "(?i)(^\s*(\$)checksum\s*=\s*)('.*')"     = "`$1'$($Latest.Checksum64)'"
            "(?i)(^\s*(\$)checksumType\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType64)'"
        }
    }
}

update -ChecksumFor 64

$ErrorActionPreference = "Stop"

import-module Chocolatey-AU
# Page containing download links
$releases = 'https://www.token2.com/site/page/token2-companion-app-v2-user-manual'

function Convert-ToNuGetVersion($version) {

    # Converts vendor versions:
    # 2.0.2_R6 -> 2.0.2.6
    # 2.0.1    -> 2.0.1

    if ($version -match '^(\d+\.\d+\.\d+)_R(\d+)$') {
        return "$($matches[1]).$($matches[2])"
    }

    if ($version -match '^\d+\.\d+\.\d+$') {
        return $version
    }

    throw "Unknown version format: $version"
}

function Get-VersionObject($version) {

    # Creates comparable version object for sorting
    [version](Convert-ToNuGetVersion $version)
}

function global:au_GetLatest {

    # Download page content
    $page = Invoke-WebRequest -Uri $releases -UseBasicParsing

    # Find ALL matching download links
    $regex = '/soft/Token2_Companion_App-(?<version>[\d\._R]+)\.zip'

    $matches = [regex]::Matches($page.Content, $regex)

    if ($matches.Count -eq 0) {
        throw "No download links found."
    }

    # Collect all versions
    $versions = foreach ($m in $matches) {
        $raw = $m.Groups['version'].Value

        [PSCustomObject]@{
            RawVersion   = $raw
            NuGetVersion = Convert-ToNuGetVersion $raw
            VersionObj   = Get-VersionObject $raw
        }
    }

    # Select highest version
    $latest = $versions |
        Sort-Object VersionObj -Descending |
        Select-Object -First 1

    $url = "https://www.token2.com/soft/Token2_Companion_App-$($latest.RawVersion).zip"

    return @{
        Version       = $latest.NuGetVersion
        URL32         = $url
        PackageSource = $latest.RawVersion
    }
}

function global:au_BeforeUpdate {

    # Download installer and calculate checksums
    Get-RemoteFiles -Purge -NoSuffix
}

function global:au_SearchReplace {

    @{
        ".\token2-companion.nuspec" = @{
            "(?i)(<version>).*?(</version>)" = "`${1}$($Latest.Version)`${2}"
        }

        ".\tools\chocolateyinstall.ps1" = @{
            "(?i)(^\s*\`$url\s*=\s*)'.*'"          = "`$1'$($Latest.URL32)'"
            "(?i)(^\s*\`$checksum\s*=\s*)'.*'"     = "`$1'$($Latest.Checksum32)'"
            "(?i)(^\s*\`$checksumType\s*=\s*)'.*'" = "`$1'$($Latest.ChecksumType32)'"
        }
    }
}

update -ChecksumFor none

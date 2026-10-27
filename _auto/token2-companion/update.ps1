$ErrorActionPreference = "Stop"

import-module Chocolatey-AU

# Page containing download links
$releases = 'https://www.token2.com/pages/token2-companion-app-v2-user-manual'

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

function Get-DownloadCandidate($href) {
    if ([string]::IsNullOrWhiteSpace($href)) { return }
    $downloadUri = [uri]::new([uri]$releases, [System.Net.WebUtility]::HtmlDecode($href))
    if ($downloadUri.Scheme -ne 'https' -or $downloadUri.Host -ne ([uri]$releases).Host) { return }
    $versionPattern = '\d+\.\d+\.\d+(?:_R\d+)?'
    $pathPattern = "^/soft/(?:Token2_Companion_App-(?<version>$versionPattern)|upl/Token2CompanionAppWindows\((?<version>$versionPattern)\))\.zip$"
    if ([uri]::UnescapeDataString($downloadUri.AbsolutePath) -cmatch $pathPattern) {
        $rawVersion = $Matches.version
        [PSCustomObject]@{
            RawVersion   = $rawVersion
            NuGetVersion = Convert-ToNuGetVersion $rawVersion
            VersionObj   = Get-VersionObject $rawVersion
            Url          = $downloadUri.AbsoluteUri
        }
    }
}

function Get-LatestDownload($candidates) {
    $latest = $candidates |
        Sort-Object VersionObj -Descending |
        Select-Object -First 1
    $latestDownloads = @($candidates |
        Where-Object { $_.VersionObj -eq $latest.VersionObj } |
        Sort-Object Url -Unique)
    if ($latestDownloads.Count -ne 1) {
        throw "Ambiguous Windows downloads for version $($latest.NuGetVersion): $($latestDownloads.Url -join ', ')"
    }
    return $latestDownloads[0]
}

function global:au_GetLatest {
    $page = Invoke-WebRequest -Uri $releases -UseBasicParsing
    $candidates = @($page.Links | ForEach-Object { Get-DownloadCandidate $_.href })
    if ($candidates.Count -eq 0) {
        throw "No Windows download links found at $releases (HTTP $($page.StatusCode)); expected a versioned Token2 Companion App ZIP."
    }
    $latest = Get-LatestDownload $candidates
    return @{
        Version       = $latest.NuGetVersion
        URL32         = $latest.Url
        PackageSource = $latest.RawVersion
    }
}

function global:au_BeforeUpdate {

    # Download installer and calculate checksums
    Get-RemoteFiles -Purge -NoSuffix
}

function global:au_SearchReplace {
    $year = (Get-Date).Year

    @{
        ".\token2-companion.nuspec" = @{
            "(?i)(<version>).*?(</version>)"                    = "`${1}$($Latest.Version)`${2}"
            "(?i)(<copyright>.*?Copyright\s+\d{4}\s*-\s*)\d{4}" = "`${1}$year"
        }

        ".\tools\chocolateyinstall.ps1" = @{
            "(?i)(^\s*\`$url\s*=\s*)'.*'"          = "`$1'$($Latest.URL32)'"
            "(?i)(^\s*\`$checksum\s*=\s*)'.*'"     = "`$1'$($Latest.Checksum32)'"
            "(?i)(^\s*\`$checksumType\s*=\s*)'.*'" = "`$1'$($Latest.ChecksumType32)'"
        }

        ".\tools\VERIFICATION.txt" = @{
            "(?i)(^Download URL\s*:\s*).*"           = "`${1}$($Latest.URL32)"
            "(?i)(^Checksum \(sha256\)\s*:\s*).*"     = "`${1}$($Latest.Checksum32)"
        }
    }
}

update -ChecksumFor none

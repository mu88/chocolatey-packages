Param (
    [string]$GitHubToken
)

Import-Module Chocolatey-AU

function global:au_GetLatest {
    $authSplat = @{}
    if ($GitHubToken) {
        $authSplat = @{
            Authentication = 'Bearer'
            Token = ($GitHubToken | ConvertTo-SecureString -AsPlainText)
        }
    }

    $latestRelease = Invoke-RestMethod -UseBasicParsing -Uri 'https://api.github.com/repos/genotrance/px/releases/latest' @authSplat
    $latestVersion = $latestRelease.tag_name
    $windowsAsset = $latestRelease.assets | Where-Object { $_.name -match '^px-v.+-windows-amd64\.zip$' } | Select-Object -First 1

    if (-not $windowsAsset) {
        throw 'Could not find px Windows amd64 zip asset in latest release.'
    }

    $assetDigest = $windowsAsset.digest
    if (-not $assetDigest -or -not $assetDigest.StartsWith('sha256:')) {
        throw 'Could not determine SHA256 digest for px Windows amd64 asset.'
    }

    return @{
        URL64 = $windowsAsset.browser_download_url
        Version = if ($latestVersion.StartsWith('v')) { $latestVersion.Substring(1) } else { $latestVersion }
        Checksum64 = $assetDigest.Substring(7)
        ChecksumType64 = 'sha256'
    }
}

function global:au_SearchReplace {
    @{
        '.\px-proxy.nuspec' = @{
            '(?i)(<version>).*?(</version>)' = "`${1}$($Latest.Version)`${2}"
        }

        '.\tools\chocolateyInstall.ps1' = @{
            "(?i)(^\s*(\$)url64\s*=\s*)('.*')" = "`$1'$($Latest.URL64)'"
            "(?i)(^\s*(\$)checksum64\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
            "(?i)(^\s*(\$)checksumType64\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType64)'"
        }
    }
}

Update

param (
    [string]$GitHubToken
)

$ErrorActionPreference = 'Stop'

Import-Module Chocolatey-AU

function global:au_GetLatest {
    $authSplat = @{}
    if ($GitHubToken) {
        $authSplat = @{
            Authentication = 'Bearer'
            Token          = (ConvertTo-SecureString -String $GitHubToken -AsPlainText -Force)
        }
    }

    $latestRelease = $null
    $latestVersion = [version]'0.0'
    $page = 1
    do {
        $uri = "https://api.github.com/repos/anomalyco/opencode/releases?per_page=100&page=$page"
        $response = Invoke-RestMethod -UseBasicParsing -Uri $uri @authSplat
        $releases = @($response)
        foreach ($release in $releases) {
            if ($release.draft -or $release.prerelease -or $release.tag_name -cnotmatch '^v2\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$') {
                continue
            }

            $version = [version]$release.tag_name.Substring(1)
            if ($version -gt $latestVersion) {
                $latestVersion = $version
                $latestRelease = $release
            }
        }
        $page++
    } while ($releases.Count -eq 100)

    if ($null -eq $latestRelease) {
        throw 'No stable v2 release found in anomalyco/opencode.'
    }

    $windowsAssets = @($latestRelease.assets | Where-Object { $_.name -ceq 'opencode-windows-x64.zip' })
    if ($windowsAssets.Count -ne 1) {
        throw "Expected exactly one opencode-windows-x64.zip asset in release '$($latestRelease.tag_name)', found $($windowsAssets.Count)."
    }

    $windowsAsset = $windowsAssets[0]
    $expectedUrl = "https://github.com/anomalyco/opencode/releases/download/$($latestRelease.tag_name)/opencode-windows-x64.zip"
    if ($windowsAsset.browser_download_url -cne $expectedUrl) {
        throw "Unexpected Windows x64 download URL in release '$($latestRelease.tag_name)'."
    }

    if ($windowsAsset.digest -cnotmatch '^sha256:[0-9a-f]{64}$') {
        throw "Missing or invalid Windows x64 SHA256 digest in release '$($latestRelease.tag_name)'."
    }

    return @{
        URL64          = $expectedUrl
        Version        = $latestVersion.ToString()
        Checksum64     = $windowsAsset.digest.Substring(7)
        ChecksumType64 = 'sha256'
    }
}

function global:au_SearchReplace {
    $year = (Get-Date).Year

    @{
        '.\opencode2.nuspec' = @{
            '(<copyright>Copyright \(c\) \d{4} - )\d{4}( opencode</copyright>)' = "`${1}$year`${2}"
        }
        '.\tools\chocolateyInstall.ps1' = @{
            '(?i)^(\s*\$url64\s*=\s*)''[^'']*'''      = "`$1'$($Latest.URL64)'"
            '(?i)^(\s*\$checksum64\s*=\s*)''[^'']*''' = "`$1'$($Latest.Checksum64)'"
        }
    }
}

Update -ChecksumFor 64

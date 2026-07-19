Param (
    [string]$GitHubToken
)

$ErrorActionPreference = 'Stop'

Import-Module Chocolatey-AU

function Convert-ToNuGetVersion([string]$TagName) {
    if ($TagName -match '^v?(?<major>\d+)\.(?<minor>\d+)(?:\.(?<patch>\d+))?(?:-SP(?<servicePack>\d+))?$') {
        $major = $matches['major']
        $minor = $matches['minor']
        $patch = $matches['patch']
        $servicePack = $matches['servicePack']

        if ($servicePack) {
            if ($patch) {
                return "$major.$minor.$patch.$servicePack"
            }

            return "$major.$minor.$servicePack"
        }

        if ($patch) {
            return "$major.$minor.$patch"
        }

        return "$major.$minor"
    }

    throw "Unsupported Golden Cheetah tag format: '$TagName'."
}

function global:au_GetLatest {
    $authSplat = @{}
    if ($GitHubToken) {
        $authSplat = @{
            Authentication = 'Bearer'
            Token = ($GitHubToken | ConvertTo-SecureString -AsPlainText)
        }
    }

    $latestRelease = Invoke-RestMethod -UseBasicParsing -Uri 'https://api.github.com/repos/GoldenCheetah/GoldenCheetah/releases/latest' @authSplat
    $windowsAsset = $latestRelease.assets |
        Where-Object { $_.name -match '^GoldenCheetah_v.+_x64Qt6\.exe$' } |
        Select-Object -First 1

    if (-not $windowsAsset) {
        throw 'Could not find Golden Cheetah Windows x64 Qt6 installer in latest release assets.'
    }

    $assetDigest = $windowsAsset.digest
    if (-not $assetDigest -or -not $assetDigest.StartsWith('sha256:')) {
        throw 'Could not determine SHA256 digest for Golden Cheetah Windows installer.'
    }

    return @{
        URL64 = $windowsAsset.browser_download_url
        Version = Convert-ToNuGetVersion -TagName $latestRelease.tag_name
        Checksum64 = $assetDigest.Substring(7)
        ChecksumType64 = 'sha256'
    }
}

function global:au_SearchReplace {
    @{
        '.\golden-cheetah.nuspec' = @{
            '(?i)(<version>).*?(</version>)' = "`${1}$($Latest.Version)`${2}"
        }

        '.\tools\chocolateyInstall.ps1' = @{
            "(?i)(^\s*(\$)url64\s*=\s*)('.*')"          = "`$1'$($Latest.URL64)'"
            "(?i)(^\s*(\$)checksum64\s*=\s*)('.*')"     = "`$1'$($Latest.Checksum64)'"
            "(?i)(^\s*(\$)checksumType64\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType64)'"
        }

        '..\..\README.md' = @{
            "(?i)(golden-cheetah.*?Chocolatey-)([\d\.]+)(-green)" = "`${1}$($Latest.Version)`${3}"
        }
    }
}

Update -ChecksumFor 64

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
    $windowsAssets = @(
        $latestRelease.assets | Where-Object {
            $_.name -match '^GoldenCheetah_v.+_x64(?:Qt\d+)?\.exe$'
        }
    )

    if ($windowsAssets.Count -ne 1) {
        $availableAssets = $latestRelease.assets.name -join ', '
        throw "Expected exactly one Golden Cheetah Windows x64 installer but found $($windowsAssets.Count). Available assets: $availableAssets"
    }

    $windowsAsset = $windowsAssets[0]
    $assetDigest = $windowsAsset.digest
    if (-not $assetDigest -or -not $assetDigest.StartsWith('sha256:')) {
        throw 'Could not determine SHA256 digest for Golden Cheetah Windows installer.'
    }

    return @{
        URL64 = $windowsAsset.browser_download_url
        Version = Convert-ToNuGetVersion -TagName $latestRelease.tag_name
        RawTag = $latestRelease.tag_name -replace '^v', ''
        Checksum64 = $assetDigest.Substring(7)
        ChecksumType64 = 'sha256'
    }
}

function global:au_SearchReplace {
    $year = (Get-Date).Year

    @{
        '.\golden-cheetah.nuspec' = @{
            '(?i)(<version>).*?(</version>)'            = "`${1}$($Latest.Version)`${2}"
            '(?i)(cdn\.jsdelivr\.net/gh/[^@]+@v)[^/]+'  = "`${1}$($Latest.RawTag)"
            "(?i)(<copyright>.*?Copyright\s+)\d{4}"     = "`${1}$year"
        }

        '.\tools\chocolateyInstall.ps1' = @{
            "(?i)(^\s*(\$)url64\s*=\s*)('.*')"          = "`$1'$($Latest.URL64)'"
            "(?i)(^\s*(\$)checksum64\s*=\s*)('.*')"     = "`$1'$($Latest.Checksum64)'"
            "(?i)(^\s*(\$)checksumType64\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType64)'"
        }
    }
}

Update -ChecksumFor 64

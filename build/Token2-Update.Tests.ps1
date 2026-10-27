BeforeAll {
    $script:releases = 'https://www.token2.com/pages/token2-companion-app-v2-user-manual'
    $updatePath = Join-Path $PSScriptRoot '..\_auto\token2-companion\update.ps1'
    $syntaxTree = [System.Management.Automation.Language.Parser]::ParseFile(
        $updatePath, [ref]$null, [ref]$null)
    $syntaxTree.FindAll({
        param($node)
        $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
    }, $false) | ForEach-Object {
        . ([scriptblock]::Create($_.Extent.Text))
    }
}

Describe 'Token2 download discovery' {
    It 'preserves the published URL and normalizes <Version>' -ForEach @(
        @{ Href = '/soft/Token2_Companion_App-2.0.2_R6.zip'; Version = '2.0.2.6' }
        @{ Href = '/soft/Token2_Companion_App-2.0.1.zip'; Version = '2.0.1' }
        @{ Href = '/soft/upl/Token2CompanionAppWindows(2.0.4).zip'; Version = '2.0.4' }
        @{ Href = 'https://www.token2.com/soft/upl/Token2CompanionAppWindows(2.0.4).zip'; Version = '2.0.4' }
        @{ Href = '/soft/upl/Token2CompanionAppWindows%282.0.4%29.zip?one=1&amp;two=2'; Version = '2.0.4' }
    ) {
        Mock Invoke-WebRequest {
            @{ StatusCode = 200; Links = @(@{ href = $Href }) }
        }

        $latest = au_GetLatest

        $latest.Version | Should -Be $Version
        $latest.URL32 | Should -Be ([uri]::new(
            [uri]$script:releases, [System.Net.WebUtility]::HtmlDecode($Href))).AbsoluteUri
    }

    It 'selects the highest numeric version rather than document order' {
        Mock Invoke-WebRequest {
            @{ StatusCode = 200; Links = @(
                @{ href = '/soft/upl/Token2CompanionAppWindows(2.0.4).zip' }
                @{ href = '/soft/upl/Token2CompanionAppWindows(2.0.10).zip' }
                @{ href = '/soft/Token2_Companion_App-2.0.2_R6.zip' }
            ) }
        }

        (au_GetLatest).Version | Should -Be '2.0.10'
    }

    It 'rejects an unsupported or untrusted link: <Href>' -ForEach @(
        @{ Href = '/soft/upl/Token2CompanionAppMacOS(2.0.4).pkg' }
        @{ Href = '/soft/upl/Token2CompanionAppWindows(2.0.4).zip.exe' }
        @{ Href = 'https://example.com/soft/upl/Token2CompanionAppWindows(2.0.4).zip' }
        @{ Href = 'http://www.token2.com/soft/upl/Token2CompanionAppWindows(2.0.4).zip' }
        @{ Href = '/soft/upl/Token2CompanionAppWindows(unknown).zip' }
        @{ Href = '' }
    ) {
        Mock Invoke-WebRequest {
            @{ StatusCode = 200; Links = @(@{ href = $Href }) }
        }

        { au_GetLatest } | Should -Throw '*No Windows download links found*'
    }

    It 'reports a page without download links' {
        Mock Invoke-WebRequest { @{ StatusCode = 200; Links = @() } }

        { au_GetLatest } | Should -Throw "*$script:releases*HTTP 200*"
    }

    It 'rejects different downloads for the same latest version' {
        Mock Invoke-WebRequest {
            @{ StatusCode = 200; Links = @(
                @{ href = '/soft/Token2_Companion_App-2.0.4.zip' }
                @{ href = '/soft/upl/Token2CompanionAppWindows(2.0.4).zip' }
            ) }
        }

        { au_GetLatest } | Should -Throw '*Ambiguous Windows downloads*'
    }

    It 'accepts repeated links to the same download' {
        Mock Invoke-WebRequest {
            @{ StatusCode = 200; Links = @(
                @{ href = '/soft/upl/Token2CompanionAppWindows(2.0.4).zip' }
                @{ href = '/soft/upl/Token2CompanionAppWindows(2.0.4).zip' }
            ) }
        }

        (au_GetLatest).Version | Should -Be '2.0.4'
    }

    It 'propagates HTTP failures' {
        Mock Invoke-WebRequest { throw 'HTTP 503' }

        { au_GetLatest } | Should -Throw '*HTTP 503*'
    }
}

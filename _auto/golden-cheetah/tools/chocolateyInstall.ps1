$ErrorActionPreference = 'Stop'

$packageName = 'golden-cheetah'
$url64 = 'https://github.com/GoldenCheetah/GoldenCheetah/releases/download/v3.7-SP1/GoldenCheetah_v3.7-sp1_x64Qt6.exe'
$checksum64 = 'e00d3bcea114c54b64f270b9ab467d1513207d296de85cae2bb1ac2ae25a355f'
$checksumType64 = 'sha256'

$packageArgs = @{
    PackageName = $packageName
    FileType = 'exe'
    SilentArgs = '/S'
    Url64bit = $url64
    Checksum64 = $checksum64
    ChecksumType64 = $checksumType64
}

Install-ChocolateyPackage @packageArgs

$ErrorActionPreference = 'Stop'

$packageName = 'golden-cheetah'
$url64 = 'https://github.com/GoldenCheetah/GoldenCheetah/releases/download/v3.8/GoldenCheetah_v3.8_x64.exe'
$checksum64 = '7aae10c26f67698a690505ec0b3011f7c8e6b7a12cd5026f8a175579b4598c58'
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

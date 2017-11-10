$hostname = "navex-cside"

# SETTINGS:
. (Join-Path $PSScriptRoot '..\helpers\Init-Environment.ps1')
$passsec = & (Join-Path $PSScriptRoot '..\helpers\Get-PwdSecured.ps1') -keyFile ".\my\myAES.key"

docker run `
    -m 2G `
    --name $hostname `
    --hostname $hostname `
    -v $PSScriptRoot\my:c:\run\my `
    -e Accept_eula=Y `
    -e Auth=Windows `
    -e username=$env:USERNAME `
    -e securePassword=$passsec `
    -e passwordKeyFile='c:\run\my\myAES.key' `
    -e enableSymbolLoading=Y `
    ${NAV_DOCKER_IMAGE}

$passplain = $null
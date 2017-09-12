$hostname = "navex-cside"

# SETTINGS:
. (Join-Path $PSScriptRoot '..\helpers\Init-Environment.ps1')
$passplain = & (Join-Path $PSScriptRoot '..\helpers\Get-Pwd.ps1')

docker run `
    --rm `
    -m 3G `
    --name $hostname `
    --hostname $hostname `
    -v $PSScriptRoot\my:c:\run\my `
    -e Accept_eula=Y `
    -e Auth=Windows `
    -e username=Jakub `
    -e password=$passplain `
    ${NAV_DOCKER_IMAGE}

$passplain = $null
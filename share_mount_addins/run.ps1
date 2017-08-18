$hostname = "navex-share-mount-addins"

# SETTINGS:
. (Join-Path $PSScriptRoot '..\helpers\Init-Environment.ps1')
$navVersionDir = & (Join-Path $PSScriptRoot '..\helpers\Get-NavVersionDir.ps1')
$passplain = & (Join-Path $PSScriptRoot '..\helpers\Get-Pwd.ps1')

# DOCKER RUN:
docker run `
    --rm `
    -m 3G `
    --name $hostname `
    --hostname $hostname `
    -v $PSScriptRoot\Add-ins:"C:\Program Files\Microsoft Dynamics NAV\$navVersionDir\Service\Add-ins\Docker-Share" `
    -e Accept_eula=Y `
    -e Auth=Windows `
    -e username=Jakub `
    -e password=$passplain `
    ${NAV_DOCKER_IMAGE}

$passplain = $null
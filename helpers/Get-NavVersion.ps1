[CmdletBinding()]
param (

)

. (Join-Path $PSScriptRoot 'Test-NavImage.ps1')

$navVersion = docker inspect -f '{{ index .Config.Labels \"version\" }}' ${NAV_DOCKER_IMAGE}

if ([System.String]::IsNullOrEmpty($navVersion)) {
    Write-Error "The image $NAV_DOCKER_IMAGE does not contain label 'version'."
    return -1
}

$navVersion = [version]$navVersion

return $navVersion
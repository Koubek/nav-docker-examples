[CmdletBinding()]
param (

)

if ([System.String]::IsNullOrEmpty(${NAV_DOCKER_IMAGE})) {
    Write-Error "You have to specify the image using 'NAV_DOCKER_IMAGE' variable. Please, read the main README.md file"
    return -1
}
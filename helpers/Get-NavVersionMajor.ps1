[CmdletBinding()]
param (
    
)

$navVersion = . (Join-Path $PSScriptRoot 'Get-NavVersion.ps1')
$majorPart = $navVersion.Major

return $majorPart;
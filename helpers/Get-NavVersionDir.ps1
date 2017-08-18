[CmdletBinding()]
param (
    
)

$majorPart = . (Join-Path $PSScriptRoot 'Get-NavVersionMajor.ps1')
$navVersionDir = -join ($majorPart, "0")

return $navVersionDir;
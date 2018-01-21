Write-Host "Installing Custom Modules"

Write-Host " => Installing: RSAT-AD-PowerShell"
Import-Module ServerManager
Add-WindowsFeature RSAT-AD-PowerShell

Write-Host "Custom Modules Installation Finished"
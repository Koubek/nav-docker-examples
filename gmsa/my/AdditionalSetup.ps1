# Invoke default behavior
. (Join-Path $runPath $MyInvocation.MyCommand.Name)

if ($exportClientFolder -eq "Y") {
    Export-ClientFolder $exportClientFolderPath
}

. 'C:\Run\Prompt.ps1'

if (!$restartingInstance) {
    . (Join-Path $PSScriptRoot 'MyCustomScripts\InstallModules.ps1')
}

Write-Host "Importing NAV users"
. (Join-Path $PSScriptRoot 'MyCustomScripts\SetupMyUsers.ps1') *>$null
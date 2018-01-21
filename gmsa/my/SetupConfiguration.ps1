# Invoke default behavior
. (Join-Path $runPath $MyInvocation.MyCommand.Name)

Write-Host "Running Custom SetupConfiguration.ps1" -ForegroundColor Yellow

$customConfig.SelectSingleNode("//appSettings/add[@key='BufferedInsertEnabled']").Value = "false"
# $customConfig.SelectSingleNode("//appSettings/add[@key='EnableTaskScheduler']").Value = "true"
$customConfig.SelectSingleNode("//appSettings/add[@key='ServicesLanguage']").Value = "es-ES"
$customConfig.SelectSingleNode("//appSettings/add[@key='ServicesDefaultTimeZone']").Value = "Server Time Zone"

$CustomConfig.Save($CustomConfigFile)

Write-Host "Custom SetupConfiguration.ps1 has been successfully finished." -ForegroundColor Yellow
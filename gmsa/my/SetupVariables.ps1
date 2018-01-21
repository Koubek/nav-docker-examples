# Invoke default behavior
. (Join-Path $runPath $MyInvocation.MyCommand.Name)

$exportClientFolder = 'N'
if (("$env:exportClientFolder") -and ("$env:exportClientFolder" -eq 'Y')) {
   $exportClientFolder = 'Y'
}
$exportClientFolderPath = "$env:exportClientFolderPath"
if (!$exportClientFolderPath) {
    $exportClientFolderPath = $myPath
}

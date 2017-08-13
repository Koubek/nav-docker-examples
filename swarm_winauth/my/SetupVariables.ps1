# Invoke default behavior
. (Join-Path $runPath $MyInvocation.MyCommand.Name)

if (!([System.String]::IsNullOrEmpty($env:secretPassword))) {
    $password = Get-Content(Join-Path 'C:\ProgramData\docker\secrets' $env:secretPassword)
    Remove-Item (Join-Path 'C:\ProgramData\docker\secrets' $env:secretPassword) -Force
}
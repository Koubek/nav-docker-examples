[CmdletBinding()]
param(
    [String]$SqlServerInstance = "LOCALHOST\SQLEXPRESS",
    [String]$Database = "CRONUS"
)

if ($auth -eq "Windows") {
    Invoke-Sqlcmd -InputFile (Join-Path $PSScriptRoot "SCM.t_ObjLog.sql") -ServerInstance "$SqlServerInstance" -Database $Database
    Invoke-Sqlcmd -InputFile (Join-Path $PSScriptRoot "SCM.sp_InsertToObjLog.sql") -ServerInstance "$SqlServerInstance" -Database $Database
    Invoke-Sqlcmd -InputFile (Join-Path $PSScriptRoot "SCM.tr_ObjectTrigger.sql") -ServerInstance "$SqlServerInstance" -Database $Database
} else {
    # NOT TESTED YET !!!
    $pwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword))
    Invoke-Sqlcmd -InputFile (Join-Path $PSScriptRoot "SCM.t_ObjLog.sql") -ServerInstance "$SqlServerInstance" -Database $Database -Username "sa" -Password $pwd
    Invoke-Sqlcmd -InputFile (Join-Path $PSScriptRoot "SCM.sp_InsertToObjLog.sql") -ServerInstance "$SqlServerInstance" -Database $Database -Username "sa" -Password $pwd
    Invoke-Sqlcmd -InputFile (Join-Path $PSScriptRoot "SCM.tr_ObjectTrigger.sql") -ServerInstance "$SqlServerInstance" -Database $Database -Username "sa" -Password $pwd
    $pwd = $null
}
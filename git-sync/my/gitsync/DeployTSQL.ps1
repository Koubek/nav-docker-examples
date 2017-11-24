[CmdletBinding()]
param(
    [String]$SqlServerInstance = "LOCALHOST\SQLEXPRESS",
    [String]$Database = "CRONUS"
)

Invoke-Sqlcmd -InputFile (Join-Path $PSScriptRoot "SCM.t_ObjLog.sql") -ServerInstance "$SqlServerInstance" -Database $Database
# Invoke-Sqlcmd -InputFile (Join-Path $PSScriptRoot "SCM.t_ObjectMetadata.sql") -ServerInstance "$SqlServerInstance" -Database $Database
# Invoke-Sqlcmd -InputFile (Join-Path $PSScriptRoot "SCM.t_ObjLogDetail.sql") -ServerInstance "$SqlServerInstance" -Database $Database

Invoke-Sqlcmd -InputFile (Join-Path $PSScriptRoot "SCM.sp_InsertToObjLog.sql") -ServerInstance "$SqlServerInstance" -Database $Database
Invoke-Sqlcmd -InputFile (Join-Path $PSScriptRoot "SCM.tr_ObjectTrigger.sql") -ServerInstance "$SqlServerInstance" -Database $Database
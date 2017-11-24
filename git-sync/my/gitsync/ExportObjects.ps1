[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [String]$RepoPath,
    [String]$SqlServerInstance = "LOCALHOST\SQLEXPRESS",
    [String]$Database = "CRONUS",
    [Boolean]$CompleteSync = $false
)

try {        
    
    if (!(Test-Path $repoPath))
    {
        #git init $repoPath
        $completeSync = $true
        New-Item -Path $repoPath -ItemType Directory -Force | Out-Null
    }

    $localWorkPath = Join-Path $repoPath 'TEMPEXP'
    if (!(Test-Path $localWorkPath)) {
        New-Item $localWorkPath -Type Directory -Force | Out-Null
        '*' | Set-Content (Join-Path $localWorkPath '.gitignore')
    }

    $expFile =  Join-Path $localWorkPath 'NAV_AutoExport.txt'

    if (!$completeSync) {
        $objCountInFolder = Get-ChildItem $repoPath -Filter '*.TXT' | Measure-Object
        if ($objCountInFolder.Count -eq 0) {
            $completeSync = $true
        }
    }
    
    if ($completeSync)
    {        
        $module = Get-ChildItem 'C:\Program Files (x86)\Microsoft Dynamics NAV\*\RoleTailored Client\' -Filter 'NavModelTools.ps1' -Recurse
        Import-Module $module -DisableNameChecking *>$null
        
        Write-Host "Running NAV object full export. This process may take several minutes..."

        Export-NAVApplicationObject -DatabaseName $database -DatabaseServer $SqlServerInstance -Path $expFile -Force | Out-Null
        if (Test-Path($expFile))
        {
            if ((Get-Item $expFile).length -gt 0kb)
            {
                Remove-Item -Path (Join-Path $repoPath '*.TXT') -Force                
                Split-NAVApplicationObjectFile -Source $expFile -Destination $repoPath -Force
            }
            Remove-Item $expFile -Force
        }

        Write-Host "NAV object full export has been finished."
    }
    else
    {
        $pendingObjects = Invoke-Sqlcmd -Query "SELECT * FROM [dbo].[SCM.ObjectLog]" -ServerInstance "$SqlServerInstance" -Database $database
        $pendingObjCount = $pendingObjects | Measure-Object

        if ($pendingObjCount.Count -gt 0) {
            $module = Get-ChildItem 'C:\Program Files (x86)\Microsoft Dynamics NAV\*\RoleTailored Client\' -Filter 'NavModelTools.ps1' -Recurse
            Import-Module $module -DisableNameChecking *>$null
        }
        
        foreach ($obj in $pendingObjects) {
        
            $objType = $obj.Item("Object Type")
            $objId = $obj.Item("Object ID")
            $objMod = $obj.Item("Action GUID")
            $objAction = $obj.Item("Last Action")
           
            if ($objAction -eq 3) {                
                # DELETE action - we need to remove an existing file.

                # TableData,Table,,Report,,Codeunit,XMLport,MenuSuite,Page,Query,System,FieldNumber
                # This should be retrieved using a function to optimize the code.
                switch ($objType) {
                    1 { $objFilePrefix = 'TAB' }
                    # 2 { $objFilePrefix = 'FOR' }
                    3 { $objFilePrefix = 'REP' }
                    5 { $objFilePrefix = 'COD' }
                    6 { $objFilePrefix = 'XML' }
                    7 { $objFilePrefix = 'MEN' }
                    8 { $objFilePrefix = 'PAG' }
                    9 { $objFilePrefix = 'QUE' }                
                }

                $fileToRemove = Join-Path $repoPath "$objFilePrefix$objId.TXT"
                if (Test-Path $fileToRemove) {
                    Remove-Item $fileToRemove -Force
                }
            }

            Export-NAVApplicationObject -DatabaseName $database -DatabaseServer $SqlServerInstance -Path $expFile -Filter "Type=$objType;ID=$objId" -Force | Out-Null

            Invoke-Sqlcmd -Query "DELETE FROM [dbo].[SCM.ObjectLog] WHERE ([Object Type] = $objType) AND ([Object ID] = $objId) AND ([Action GUID] = '$objMod')" `
                -ServerInstance "$SqlServerInstance" -Database $database

            if (Test-Path($expFile))
            {
                if ((Get-Item $expFile).length -gt 0kb)
                {
                    Split-NAVApplicationObjectFile -Source $expFile -Destination $repoPath -Force
                }
                Remove-Item $expFile -Force
            }
        }
    }
}
catch {    
    Write-Warning "ERROR MSG: $($_.Exception.Message)"
    Write-Warning "ERROR TRACE: $($_.ScriptStackTrace)"
}

# Invoke default behavior
. (Join-Path $runPath $MyInvocation.MyCommand.Name)

function Export-ClientFolder 
{
    [CmdletBinding()]
    param(
        [string]$Path
    )

    if ([System.String]::IsNullOrEmpty($Path)) {
        $Path = $myPath;
    }

    if (!(Test-Path "$Path\RoleTailored Client" -PathType Container)) {
        Write-Host "Copy RoleTailoted Client files"
        Copy-Item -path $roleTailoredClientFolder -destination $Path -force -Recurse -ErrorAction Ignore

        $sqlServerName = if ($databaseServer -eq "localhost") { $hostname } else { $databaseServer }
        if (!([System.String]::IsNullOrEmpty($databaseInstance))) {
            $sqlServerName = "$sqlServerName\$databaseInstance"
        }
    
        $ntAuth = if ($auth -eq "Windows") { $true } else { $false }

        $ClientUserSettingsFileName = "$runPath\ClientUserSettings.config"
        [xml]$ClientUserSettings = Get-Content $clientUserSettingsFileName
        $clientUserSettings.SelectSingleNode("//configuration/appSettings/add[@key='Server']").value = "$hostname"
        $clientUserSettings.SelectSingleNode("//configuration/appSettings/add[@key='ServerInstance']").value="NAV"
        $clientUserSettings.SelectSingleNode("//configuration/appSettings/add[@key='ServicesCertificateValidationEnabled']").value="false"
        $clientUserSettings.SelectSingleNode("//configuration/appSettings/add[@key='ClientServicesPort']").value="$publicWinClientPort"
        $clientUserSettings.SelectSingleNode("//configuration/appSettings/add[@key='ACSUri']").value = ""
        $clientUserSettings.SelectSingleNode("//configuration/appSettings/add[@key='DnsIdentity']").value = "$dnsIdentity"
        $clientUserSettings.SelectSingleNode("//configuration/appSettings/add[@key='ClientServicesCredentialType']").value = "$Auth"
        $clientUserSettings.Save("$Path\RoleTailored Client\ClientUserSettings.config")        

        New-FinSqlExeRunner -FileFullPath "$Path\RoleTailored Client\_finsql-on-docker.exe" `
            -SqlServerName $sqlServerName `
            -DbName "$databaseName" `
            -NtAuth $ntAuth `
            -Id "docker_$hostname" `
            -GenerateSymbolRef ($enableSymbolLoadingAtServerStartup -eq $true)
    }
}

function New-FinSqlExeRunner
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)]
        [string]$FileFullPath,
        [Parameter(Mandatory=$True)]
        [string]$SqlServerName,
        [Parameter(Mandatory=$True)]
        [string]$DbName,
        [Parameter(Mandatory=$True)]
        [bool]$NtAuth,
        [Parameter(Mandatory=$True)]
        [string]$Id,
        [Parameter()]
        [bool]$GenerateSymbolRef=$false
    )

    $useNtAuth = If ($NtAuth) { 1 } Else { 0 }
    $fileName = Split-Path $FileFullPath -Leaf
    $buildFolder = Join-Path $PSScriptRoot '_buildfinsqlrunner'
    $iconFile = 'finsqlicon.ico'

    New-Item -ItemType Directory -Path $buildFolder -Force | Out-Null

    $generateSymbolRefStr = ""
    if ($GenerateSymbolRef -and (IsEnableSymbolLoadingSupported)) {
        $generateSymbolRefStr = ', generatesymbolreference=yes '
    }

    # Extract and prepare icon file
    $icon = [System.IO.FileStream]::new("$buildFolder\$iconFile", [System.IO.FileMode]::OpenOrCreate)
    (Get-CsideIcon).Save($icon)
    $icon.Close()
    Copy-Item "$buildFolder\$iconFile" "c:\$iconFile"
    
    Set-Content "$buildFolder\$fileName.ps1" "Start-Process '.\finsql.exe' -ArgumentList ""servername=$SqlServerName, database=$DbName, ntauthentication=$useNtAuth, id=$Id $generateSymbolRefStr""" -Force
    & (Join-Path $PSScriptRoot 'ps2exe.ps1') -inputFile "$buildFolder\$fileName.ps1" -outputFile "$buildFolder\$fileName" -iconFile "$iconFile" -noconsole -runtime40 -wait -end *>$null

    Copy-Item "$buildFolder\$fileName" $FileFullPath -Force | Out-Null

    # Cleanup
    Remove-Item $buildFolder -Recurse -Force | Out-Null
    Remove-Item "c:\$iconFile" -Force | Out-Null
}

function IsEnableSymbolLoadingSupported 
{
    [CmdletBinding()]
    param(
    )

    return ($(Get-NavVersion) -ge [System.Version]'11.0.19097.0')
}

function Get-NavVersion
{
    [CmdletBinding()]
    param(
    )

    $finSql = Get-ChildItem $roleTailoredClientFolder 'finsql.exe'
    
    return $finSql.VersionInfo.ProductVersionRaw
}

function Get-CsideIcon {
    [CmdletBinding()]
    param(
    )

    Add-Type -AssemblyName System.Drawing
    return ([Drawing.Icon]::ExtractAssociatedIcon((Get-ChildItem $roleTailoredClientFolder 'finsql.exe').FullName))
}

function Get-SqlServerAndInstance {
    [CmdletBinding()]
    param(
    )

    $sqlServerInstance = $databaseServer
    if ($databaseInstance) {
        $sqlServerInstance += "\$databaseInstance"
    }

    return $sqlServerInstance
}

function Register-NavChangeTracker {
    [CmdletBinding()]
    param(
    )

    Write-Host "Registering NAV changes tracker (T-SQL)"
    . (Join-Path $PSScriptRoot 'gitsync\DeployTSQL.ps1') -SqlServerInstance (Get-SqlServerAndInstance) -Database $databaseName
}

function Start-NavChangeTrackerExport {
    [CmdletBinding()]
    param(
        [Boolean]$CompleteSync = $false
    )
    
    . (Join-Path $PSScriptRoot 'gitsync\ExportObjects.ps1') -RepoPath $objRepoPath -SqlServer (Get-SqlServerAndInstance) -Database $databaseName -CompleteSync $CompleteSync
}

function Install-Chocolatey {
    [CmdletBinding()]
    param(        
    )

    Write-Host "Installing Chocolatey"
    $env:chocolateyUseWindowsCompression = $false
    Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) *>$null
    choco feature enable -n allowGlobalConfirmation *>$null
}

function Install-Git {
    [CmdletBinding()]
    param(
    )

    Write-Host "Installing Git"
    choco install git *>$null
}

function Register-FileSystemWatcher {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$FolderToWatch,
        [Parameter()]
        [String]$Filter = '*.*',
        [Parameter()]
        [Boolean]$IncludeSubfolders = $false,
        [Parameter()]
        [Boolean]$TrackCreate = $false,
        [Parameter()]
        [scriptblock]$OnCreateCode,
        [Parameter()]
        [Boolean]$TrackModify = $false,
        [Parameter()]
        [scriptblock]$OnModifyCode,
        [Parameter()]
        [Boolean]$TrackDelete = $false,
        [Parameter()]
        [scriptblock]$OnDeleteyCode
    )

    $fswEvents = New-Object System.Collections.ArrayList
    
    $fsw = New-Object IO.FileSystemWatcher $FolderToWatch, $Filter -Property @{IncludeSubdirectories = $IncludeSubfolders;NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'}

    if (($TrackCreate -eq $true) -and ($OnCreateCode)) {
        $createEventIdentifier = [guid]::NewGuid()
        Register-ObjectEvent $fsw Created -SourceIdentifier $createEventIdentifier -Action $OnCreateCode
        $fswEvents.Add($createEventIdentifier)
    }

    if (($TrackModify -eq $true) -and ($OnModifyCode)) {
        $modifyEventIdentifier = [guid]::NewGuid()
        Register-ObjectEvent $fsw Changed -SourceIdentifier $modifyEventIdentifier -Action $OnModifyCode
        $fswEvents.Add($modifyEventIdentifier)
    }

    if (($TrackDelete -eq $true) -and ($OnDeleteyCode)) {
        $deleteEventIdentifier = [guid]::NewGuid()
        Register-ObjectEvent $fsw Changed -SourceIdentifier $deleteEventIdentifier -Action $OnDeleteyCode
        $fswEvents.Add($deleteEventIdentifier)
    }
}

function Get-ObjectTypeFilePrefix {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Int]$ObjType
    )

    switch ($ObjType) {
        1 { $objFilePrefix = 'TAB' }
        # 2 { $objFilePrefix = 'FOR' }
        3 { $objFilePrefix = 'REP' }
        5 { $objFilePrefix = 'COD' }
        6 { $objFilePrefix = 'XML' }
        7 { $objFilePrefix = 'MEN' }
        8 { $objFilePrefix = 'PAG' }
        9 { $objFilePrefix = 'QUE' }
    }

    return $objFilePrefix
}

function Get-ObjectTypeIdFromFilename {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$Filename
    )

    $prefix = $Filename.Substring(0, 3)

    switch ($prefix) {
        'TAB' { $objType = 1 }
        # 'FOR' { $objType = 2 }
        'REP' { $objType = 3 }
        'COD' { $objType = 5 }
        'XML' { $objType = 6 }
        'MEN' { $objType = 7 }
        'PAG' { $objType = 8 }
        'QUE' { $objType = 9 }
    }

    [Int]$objId = $Filename.Substring(3)

    return { $objType, $objId }
}

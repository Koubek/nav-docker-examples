# Invoke default behavior
. (Join-Path $runPath $MyInvocation.MyCommand.Name)

function Export-ClientFolder 
{
    [CmdletBinding()]
    param(
        [string]$Path
    )

    if ([System.String]::IsNullOrEmpty($Path)) {
        return
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

function Get-CsideIcon {
    [CmdletBinding()]
    param(
    )

    Add-Type -AssemblyName System.Drawing
    return ([Drawing.Icon]::ExtractAssociatedIcon((Get-ChildItem $roleTailoredClientFolder 'finsql.exe').FullName))
}
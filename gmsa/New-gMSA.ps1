function New-gMSA 
{
    param (

        [Parameter(Mandatory=$true)]
        [String[]]$HostNames,

        [Parameter(Mandatory=$false)]
        [String]$SecGroupPath = 'OU=gMSA for Windows Containers,DC=mydomain,DC=com',

        [Parameter(Mandatory=$false)]
        [String[]]$PrincipalsAllowedToRetrieveManagedPassword = @( 'DockerGMSAGroup' )

    )

    Import-Module (Join-Path $PSScriptRoot CredentialSpec.psm1)

    foreach ($hostname in $HostNames)
    {
        $account = $null
        $dnsroot = (Get-ADDomain).DNSRoot
        $dnsHostName = $hostName + '.' + $dnsroot

        $account = Get-ADServiceAccount -Filter { cn -eq $hostName }

        if ($account -eq $null) 
        {
            Write-Verbose "Creating ADServiceAccount..."
            $account = New-ADServiceAccount -name $hostName `
                -DnsHostName $dnsHostName `
                -Path $SecGroupPath `
                -PrincipalsAllowedToRetrieveManagedPassword $PrincipalsAllowedToRetrieveManagedPassword `
                -PassThru
                

            foreach ($group in $PrincipalsAllowedToRetrieveManagedPassword)
            {
                Add-ADGroupMember $group $account
            }

        } else 
        {
            Write-Verbose "ADServiceAccount already exists."
        }

        New-CredentialSpec -Name $hostName -AccountName $hostName
    }
}
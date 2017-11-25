$hostname = "navex-sqltrace"

if ([System.String]::IsNullOrEmpty(${NAV_DOCKER_IMAGE})) {
    Write-Warning "You have to specify the image using 'NAV_DOCKER_IMAGE' variable. Please, read the main README.md file"
    Write-Warning "Example: `$NAV_DOCKER_IMAGE = 'microsoft/dynamics-nav'"
    Write-Warning "Exiting..."
    exit 1
}

# SETTINGS:
# Create AES key to encrypt the password:
$KeyFile = ".\my\myAES.key"
$Key = New-Object Byte[] 16   # You can use 16, 24, or 32 for AES
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | out-file $KeyFile

$passsec = Read-Host 'Input the user`s password' -AsSecureString
$passsec = ConvertFrom-SecureString $passsec -Key $Key

docker run `
    -m 4G `
    --name $hostname `
    --hostname $hostname `
    -v $PSScriptRoot\my:c:\run\my `
    -v $PSScriptRoot\repo:c:\gitrepo `
    -e Accept_eula=Y `
    -e Auth=Windows `
    -e username=$env:USERNAME `
    -e securePassword=$passsec `
    -e passwordKeyFile='c:\run\my\myAES.key' `
    -e licensefile='c:\run\my\_license.flf' `
    -e objRepoPath=c:\gitrepo `
    -e enableSymbolLoading=Y `
    -e ExitOnError=N `
    ${NAV_DOCKER_IMAGE}

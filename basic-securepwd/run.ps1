$hostname = "navex-basic-securepwd"

# Create AES key to encrypt the password:
$KeyFile = ".\my\myAES.key"
$Key = New-Object Byte[] 16   # You can use 16, 24, or 32 for AES
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | out-file $KeyFile

$passsec = Read-Host 'Input the user`s password' -AsSecureString
$passsec = ConvertFrom-SecureString $passsec -Key $Key

docker run `
    --rm `
    -m 3G `
    --name $hostname `
    --hostname $hostname `
    -v $PSScriptRoot\my:c:\run\my `
    -e Accept_eula=Y `
    -e Auth=Windows `
    -e username=$env:USERNAME `
    -e securePassword=$passsec `
    -e passwordKeyFile='c:\run\my\myAES.key' `
    -e clickonce=Y `
    ${NAV_DOCKER_IMAGE}
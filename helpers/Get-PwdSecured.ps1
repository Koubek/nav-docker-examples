[CmdletBinding()]
param (
    [string]$keyFile
)


# Create AES key to encrypt the password:
$Key = New-Object Byte[] 16   # You can use 16, 24, or 32 for AES
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | out-file $KeyFile

$passsec = Read-Host 'Input the user`s password' -AsSecureString
$passsec = ConvertFrom-SecureString $passsec -Key $Key

return $passsec
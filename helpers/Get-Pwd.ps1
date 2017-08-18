[CmdletBinding()]
param (

)

$passsec = Read-Host 'Input the user`s password' -AsSecureString
$passplain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($passsec))

return $passplain
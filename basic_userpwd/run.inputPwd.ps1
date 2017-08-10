$hostname = "navex-basic-userpwd"

$passsec = Read-Host 'Input the user`s password' -AsSecureString
$passplain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($passsec))

docker run `
    --rm `
    -m 3G `
    --name $hostname `
    --hostname $hostname `
    -e "Accept_eula=Y" `
    -e "username=NavUser1" `
    -e "password=$passplain" `
    ${NAV_DOCKER_IMAGE}

$passplain = $null
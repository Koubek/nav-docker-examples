$hostname = "navex-basic-winauth"

$passsec = Read-Host 'Input the user`s password' -AsSecureString
$passplain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($passsec))

docker run `
    --rm `
    -m 3G `
    --name $hostname `
    --hostname $hostname `
    -e Accept_eula=Y `
    -e Auth=Windows `
    -e username=Jakub `
    -e password=$passplain `
    -e clickonce=Y `
    ${NAV_DOCKER_IMAGE}

$passplain = $null
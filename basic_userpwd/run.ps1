docker run `
    --rm `
    -m 3G `
    --name "navex-basic-userpwd_container" `
    --hostname "navex-basic-userpwd" `
    -e "Accept_eula=Y" `
    -e "username=NavUser1" `
    -e "password=NavUser1Password" `
    ${NAV_DOCKER_IMAGE}
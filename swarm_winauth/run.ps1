$hostname = "navex-swarm-winauth"

docker service create `
    --name=$hostname `
    --hostname=$hostname `
    --limit-memory=2G `
    --secret=mywinuser_win_pwd `
    --mount type=bind,source=$PSScriptRoot\my,destination=c:\run\my `
    --health-interval=60s `
    --health-timeout=20s `
    --health-retries=5 `
    -e Accept_eula=Y `
    -e Auth=Windows `
    -e clickonce=Y `
    -e username=$env:USERNAME `
    -e secretPassword=mywinuser_win_pwd `
    ${NAV_DOCKER_IMAGE}
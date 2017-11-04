# Examples and use-cases for MS Dynamics NAV on Docker

## !!! IMPORTANT !!!

At this moment, all examples use Docker images for MS Dynamics NAV provided by Microsoft. 

~~Microsoft at the moment doesn\`t provide the images in the public repositories (e.g. [Docker Hub](https://hub.docker.com/)). Instead, there is a private repository for testing purposes only. Currently, they have been opened to give the access to the private/testing repository to *anyone* interested and willing to do some tests and provide a feedback. This can change at any moment I suppose.~~

Microsoft has recently started with publishing of the images into the official [Docker Hub](https://hub.docker.com/r/microsoft/dynamics-nav/). Currently anyone can start using NAV on Docker. Please, read all the information in the repository to understand which version will be published in the repo, how to localize them and for what purposes you are allowed to use them. Microsoft, many thanks!!!

Also, you can visit Microsoft GitHub repository [nav-docker](https://github.com/Microsoft/nav-docker) with the source code they use to build the images. There, you can also register any issue that will appear during the testing.

It is pretty possible that some examples could fail because of the breaking changes in the sources images. Please, in this case I will appreciate your feedback (create an issue).

## PREREQUISITES AND GENERAL SETUP
- [Docker](https://www.docker.com/) has to be installed and properly configured on your **Win10** / **WinServer2016** (or higher) machine. Some examples will need some extra setups but those will be described for each example explicitly. 
- If you want to install **Docker EE** on your Windows Server you can use [InstallDockerEE.ps1](https://gist.github.com/Koubek/1831c2aba7f558de4b1461476105ba85) script that will install **Containers** Windows Feature and then **Docker EE**. The script can be used also to upgrade your current version. It detects an existing (installed) **Docker EE** version present on your host and let you compare your version with the newest one available to download and install. If you confirm the new version will be downloaded and installed. This is very useful in case you are waiting for a specific Docker release and you want to check if this release has been already pushed into the repo or not.
- By default, we will be using **NAT** network which is the default one configured during the Docker installation process. You can find more details about [Docker networking here](https://docs.microsoft.com/virtualization/windowscontainers/manage-containers/container-networking).
- All examples specify NAV docker image using `${NAV_DOCKER_IMAGE}` variable. This gives us some sort of flexibility in case Microsoft migrate the repository or change the name of the images, tags etc.
- So the first step, before you run any script including `docker run` command, is setting the variable. For example:
```powershell
# Private Microsoft Repository for NAV previews and for internal purposes.
$NAV_DOCKER_IMAGE = 'navdocker.azurecr.io/dynamics-nav:devpreview'

# Official images available on Docker Hub (I will use the last W1 version):
$NAV_DOCKER_IMAGE = 'microsoft/dynamics-nav'
```

## EXAMPLES

- [basic](basic) - This is the most elemental example. I would recommend running exactly this one at the very first moment to validate that everything is working fine. You specify the minimum of the parameters.

- [basic with user+pwd defined](basic_userpwd) - Similar to the previous one but you specify **user name**, **user pwd**, **container hostname**, **container name**. There are also described some security concerns (security of the password you use). The example includes two variants.

- [winauth (shared) + VS Code](basic_winauth) - This example demonstrates *shared* Windows authentication. We will also see new security approach that will protect your password. This security approach is applicable to any authentication mechanism (so the WinAuth is not the only one) that requires providing a password in an explicite way.

    We will created and published **ClickOnce** package. And finally, we will try to connect from **VS Code** to the container`s **dev services**.

- [winauth on Docker Swarm + Secrets](swarm_winauth) - One of the advanced scenarios. We will increase the security of your credentials using Docker Swarm\`s Secrets. We will also talk about the **scaling** capabilities of the *Docker Swarm*. You will need to promote your docker host on the [Docker Swarm](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/swarm-mode) node. But don\`t worry, this is actually quite easy to do.

- [share data using mounts](share_mount_addins) - In case you need to share (for example) **add-ins** between your *Docker host* and containers *Docker Volumes* would be probably the easiest way for you.

- [locally copied C/SIDE](local_cside) - An example that will demonstrate how to copy *client folder* down to your docker host to be able to access **C/SIDE** without installing it. You *don\`t need* to run **gMSA**. Actually, I use the *WinAuth hack* (mentioned before) in the example.

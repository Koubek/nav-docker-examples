# Examples and use-cases for MS Dynamics NAV on Docker

## !!! IMPORTANT !!!

At this moment, all examples use Docker images for MS Dynamics NAV provided by Microsoft. 

Microsoft at the moment doesn\`t provide the images in the public repositories (e.g. [Docker Hub](https://hub.docker.com/)). Instead, there is a private repository for testing purposes only. Currently, they have been opened to give an access to the private/testing repository to *anyone* interested and willing to do some tests and provide a feedback. This can change at any moment I suppose.

Also, you can visit Microsoft GitHub repository [nav-docker](https://github.com/Microsoft/nav-docker) with the source code they use to build the images. There, you can also register any issue that will appear during the testing.

Please keep in mind the clause in the GitHub repository - there is no fix plan to provide the images in the future publicly. Microsoft can delete the repository at any moment.

Also it is pretty possible that some of the examples could fail because of the breaking changes in the sources images. Please, in this case I will appreciate your feedback (create an issue).

## PREREQUISITES AND GENERAL SETUP
- [Docker](https://www.docker.com/) has to be installed and properly configured on your **Win10** / **WinServer2016** (or higher) machine. Some of the examples will need some extra setups but those will be described for each example explicitly. 
- By default we will be using **NAT** network which is the default one configured during the Docker installation process. You can find more details about [Docker networking here](https://docs.microsoft.com/virtualization/windowscontainers/manage-containers/container-networking).
- All examples specify NAV docker image using `${NAV_DOCKER_IMAGE}` variable. This gives us some sort of flexibility in case Microsoft migrate the repository or change the name of the images, tags etc.
- So the first step, before you run any script including `docker run` command, is setting the variable. For example:
```powershell
$NAV_DOCKER_IMAGE = 'navdocker.azurecr.io/dynamics-nav:devpreview'
```

## EXAMPLES

- [basic](basic) - This is the most elemental example. I would recommend to run exactly this one at the very first moment to validate that everything is working fine. You specify the minimum of the parameters.

- [basic with user+pwd defined](basic-userpwd) - Similar to the previous one but you specify **user name**, **user pwd**, **container hostname**, **container name**. There are also described some security concerns (security of the password you use). The example includes two variants.
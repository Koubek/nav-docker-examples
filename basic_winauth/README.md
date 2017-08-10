# Examples and use-cases for MS Dynamics NAV on Docker

## SHARED WINDOWS AUTHENTICATION + CLICKONCE + VISUAL STUDIO CODE

In this case we will describe a simple solution from the docker perspective. Our command `docker run` will be pretty straightforward and if you passed through the previous examples you will have no problem to understand and achieve same results as I do.

Let\`s say a word about the **Windows authentication** for **Windows Containers**. Containers **by default** doesn\`t provide mechanisms that will enable real Windows authentication for domain users. This mean you can\`t specify domain accounts for the services (for example) running inside the containers. And in a very similar way, you can\`t authenticate yourself using your domain account against the services and solutions running inside the containers.

As I have already mentioned - this behavior comes by default. But you have two options how to solve WinAuth problem:

- You can provide your credentials explicitly (pass your windows credentials into the container) and benefit from the fact that Windows authenticate correctly even in case you are on the domain (your docker host) and the container has its own workgroup inside.
You can see that the solution we have just mentioned improves somehow our possibilities, it is easy-to-achieve solution. 
On the other hand, we still need to provide our credentials and those can be revealed using the techniques mentioned in the previous example.

- You can use [gMSA](https://technet.microsoft.com/en-us/library/jj128431(v=ws.11).aspx) and solve the integration with the domain properly. Unfortunately, this steps is no so easy to achieve to. There are few prerequisites you must fulfil. One of them, and this one is the key one, goes against your **Domain Controller**. **"The Active Directory schema in the gMSA domain’s forest needs to be updated to Windows Server 2012 to create a gMSA."** I can see this requirement can be real problem for some partners and even worse situation can be seen the customers. There are lot of companies with the domain\`s forest on the 2003 level. As the objective of the example is the previous (the less secure one) solution we won\`t discuss any other details related to **gMSA** right now. There will one or more examples focused on the **gMSA** solution.


### Specific `docker run` parameters in the example are:

- `-e Auth=Windows` - Required in this example. Alternatively you can also use `-e WindowsAuth=Y` to achieve the same - setting the container work in Windows Authentication mode.

- `-e username=Jakub` - Required in this example. Set your Windows user account (**without** the domain name part).

- `-e password=$passplain` - Required in this example. Your password for the provided user account. Must match with your Windows account password!!! You can see we use the same technique demonstrated in the [previous example](../basic_userpwd) (in the second variant). You still need to provide the password what logically means we have to consider possible security issues.

- `-e clickonce=Y` - The container will create and publish **ClickOnce** package. This gives us the possibility access using Windows Client (aka RTC) and access natively using our Windows credentials.

---

## Output of the `run.ps1` script:

![](../media/basic_winauth_containerStarted.jpg)

We can see that there is no information about the user (user name and user password are not present).

## CLICKONCE

You can see there is a new link to download "ClickOnce Manifest". Use the link, open the webpage and download the manifest clicking on **Install now**.

![](../media/basic_winauth_clickOnceInstallation.jpg)

 Run the manifest. After that you should be able to see running RTC (no password will be required).

![](../media/basic_winauth_clickOnce_RTC.jpg)

**Note:**
If you are using Google Chrome (I usually do) and see some security errors when downloading and/or running the manifest, I would recommend for example **Internet Explorer** or **Edge**. Both of them work fine for my (I don\`t use *recommended settings* in IE).


## VISUAL STUDIO CODE - INSTALL THE EXTENSION / PLUGIN:

I suppose you have [Visual Studio Code](https://code.visualstudio.com/) already installed and have some experience with it.

Probably you have already mentioned there is one link in the *container output table* with the extension **vsix**. This is the extension you need to add into your *VS Code*.

Before you install the extension the **vsix** file should be downloaded. Once you have downloaded your file, go to *VS Code*, run **Command Palette** (*Ctrl + Shift + P*) and run `Extensions: Install from VSIX...`:

![](../media/basic_winauth_vsCode_installExtensionCmd.jpg)

Then you select the **vsix** file you have previously downloaded and you ready to start with development :)

**Note:**
You can eventually download the **vsix** file directly from *VS Code* in the same dialog you specify the **vsix** file. Just put the link instead of any file and the file will be downloaded and installed. It is probably the easiest way but maybe a bit less transparent than the previous one.


## VISUAL STUDIO CODE - SETUP THE PROJECT:

You can use any of the sample projects you can find online (for example). You can create an empty project and this is exactly I am going to describe here.

- Run *Ctrl + Shift + P* and run `AL: Go!` command. This will create a new project with all required files.

- Change `locale` property in `app.json` file. Switch from **US** to **W1**:

    ![](../media/basic_winauth_vsCode_changeLocale.jpg)

- Configure `launch.json` file to point to your instance running inside the container (use **Dev. Server** property`s value from the *container output table*):

    ![](../media/basic_winauth_vsCode_launchConfigAndDownloadSymbols.jpg)

Now you just click on **Download Symbols**, wait a while until the download is finished. And now you can start with your development, you have everything ready to go!!!
# To install SolidFire PowerShell as Docker container:

![solidfire-powershell-logo](../../docs/product.png) ![docker-logo](docker-logo-small.png)

### Prerequisite: 

You must have Docker engine installed and running on your host machine.  [Install the latest docker engine](https://www.docker.com/products/overview)

### Run the SolidFire Powershell Container:

Using a terminal, pull and run the latest SolidFire PowerShell image from our public Docker repo with this command:

    docker run -it -v $(pwd):/scripts netapp/solidfire-powershell

This will download that SolidFire Docker image, start a new container, and open a PowerShell shell from your terminal with the SolidFire module loaded and ready. 

**NOTE:** Any scripts in your host's pwd* will be available at `/scripts` once you are in the ?owerShell shell.

*Present Working Directory

**ProTip:**
You can change the mounted directory for `/scripts` by modifying the left side of the ':'. Use " " when a space exists in the path.
Ex: `docker run -it -v "/Users/<username>/Documents/Github/":/scripts netapp/solidfire-powershell`

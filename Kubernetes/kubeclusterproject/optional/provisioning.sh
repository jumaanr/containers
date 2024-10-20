#!/bin/bash

#--------------- Install Azure CLI (Optional)----------#
# This environment is prepped for Ubuntu Debian Kernel
#Update package sources
sudo apt-get update
#Install pre-requisites
sudo apt-get install curl apt-transport-https lsb-release gnupg
#Download and install Microsoft signing Key
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
#Add the Azure CLI software repository:
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
#Update package sources list again
sudo apt-get update
# Install Azure CLI
sudo apt-get install azure-cli
# Check version
az --version


ssh -i ~/.ssh/kubeconnect.pem azureuser@20.230.62.184

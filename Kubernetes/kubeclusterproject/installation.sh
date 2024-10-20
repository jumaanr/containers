#!/bin/bash
#---------------------- Step 03 )  Install kubeadm----------------------------#
#kubadm : the command to bootstrap the cluster
#kubelet : the component that runs on all of the machines in your cluster
#kublectl : the command line util that talk to your cluster

# ref : https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl

#---- on all 3 nodes ---#
#---------Update the apt package index and install packages needed to use the Kubernetes apt repository

sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# ----------download public signing keys for kubernetes package repositories
# If the folder `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

#----------Add the repositories
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

#-------- Install kubernetes package
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl #prevent automatically updating or upgrading the packages


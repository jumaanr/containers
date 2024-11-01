#!/bin/bash

# Prep OS : all nodes

## Install and Update Packages
sudo apt update
sudo apt list --upgradable
sudo apt upgrade
sudo apt install vim -y
sudo update-alternatives --config editor
sudo visudo
devops ALL=(ALL) NOPASSWD:ALL
sudo apt install net-tools -y
sudo apt install curl wget -y
sudo systemctl reboot

#enable relevant firewall ports (only if this is a on-prem vm)
#check required ports are open (Not necessary in Cloud Deployment) : https://kubernetes.io/docs/reference/networking/ports-and-protocols/
nc 127.0.0.1 6443 -v #method to check opened ports
nc 127.0.0.1 6443 -v
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 53
sudo ufw allow 8080
sudo ufw allow 6443/tcp
sudo ufw allow 2379/tcp
sudo ufw allow 2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10259/tcp
sudo ufw allow 10257/tcp
sudo ufw allow 10256/tcp
sudo ufw allow 30000:32767/tcp
sudo ufw allow 8472/udp
sudo ufw enable
sudo ufw reload
sudo ufw status verbose

# hostfile configuration on all nodes
echo "192.168.56.11 master" | sudo tee -a /etc/hosts
echo "192.168.56.21 w021" | sudo tee -a /etc/hosts
echo "192.168.56.22 w022" | sudo tee -a /etc/hosts
sudo cat /etc/hosts
sudo systemctl reboot

# vm01 base Network provisiong
sudo apt install network-manager -y
sudo nmcli con show

ncmli connection add con-name eth0 ifname eth0 type ethernet ipv4.addresses <address> gw4 <gateway>
nmcli connection modify eth0 ipv4.dns <dns address>
ncmli connection modify eth0 ipv4.method manual
ncmli connection modify eth0 connection.autoconnect true


sudo nmcli connection modify "Wired connection 1" \
  ipv4.addresses 10.0.0.100/24 \
  ipv4.gateway 10.0.0.1 \
  ipv4.dns 8.8.8.8 \
  ipv4.method manual


## Update hostnames
sudo hostnamectl set-hostname master
sudo hostnamectl set-hostname w021
sudo hostnamectl set-hostname w022

type $HOME\.ssh\id_rsa.pub | ssh devops@172.16.0.3 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"


ssh-keygen -t rsa -b 4096
ssh-copy-id devops@w021 #
ssh-copy-id devops@w022 #

sudo systemctl reboot

#1) Install and Configure Container Runtime : all nodes

# reference:  https://kubernetes.io/docs/setup/production-environment/container-runtimes/

## Swap configuration : https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#swap-configuration
sudo swapoff -a
sudo vim /etc/fstab
#UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx none swap sw 0 0
#/swapfile none swap sw 0 0
sudo systemctl reboot
sudo swapon --show
free -h

#Enable IPv4 packet forwarding

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system # Apply sysctl params without reboot
sysctl net.ipv4.ip_forward #Verify that net.ipv4.ip_forward is set to 1 

# Install container runtime
# Remove existing container runtimes and packages
cat /etc/*release*
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt install -y containerd

# Configure cgroup drivers
# ref: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd
ps -p 1 #check systemd distribution or other
sudo mkdir -p /etc/containerd #create configuration for containerd here
#genrate configs
containerd config default
containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep -i SystemdCgroup -B 50
systemctl status containerd
sudo systemctl restart containerd

# Install Kubernetes Components : all nodes

# ref: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl #hold the package versions to current version, so it wont change

sudo systemctl enable --now kubelet #Enable before running kubeadm
kubeadm version

# Initialize Control Plane Node : master
sudo kubeadm init --apiserver-advertise-address 192.168.56.11 --pod-network-cidr "10.244.0.0/16" --upload-certs

# Install POD Network Plugin : all nodes
#To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Alternatively, if you are the root user, you can run:

export KUBECONFIG=/etc/kubernetes/admin.conf

#You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
 # https://kubernetes.io/docs/concepts/cluster-administration/addons/
#------------- Deploy Flannel ---------------#
 wget https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
 kubectl apply -f kube-flannel.yml

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Join Worker Node to Cluster : w021, w022
#Then you can join any number of worker nodes by running the following on each as root:

sudo kubeadm join 192.168.56.11:6443 --token b87jk3.h3ti9b1qiehxyorg \
        --discovery-token-ca-cert-hash sha256:8e1591f4616c5db091665d199e0955467d579144dd6a2a5e20fb7caffb29bae1


#Fixing flannel issue
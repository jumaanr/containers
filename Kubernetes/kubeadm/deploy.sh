#!/bin/bash

#1) Deploy kubeadm

#network
vm01=192.168.56.21/24 (masternode)
vm02=192.168.56.22/24
#----------------Install container runtime

## pre-requisites
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
#verify
sysctl net.ipv4.ip_forward

# remove any previous container runtime packages
cat /etc/*release*
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt install -y containerd
#
sudo mkdir /etc/apt/keyrings #for packag manager
# Here we can install podman as well

# cgroup driver for systemd: kubeadm uses systemd by default from v22.0 onwards : https://kubernetes.io/docs/setup/production-environment/container-runtimes/#systemd-cgroup-driver
ps -p 1
# ensure container runtime set to utilize cgroup driver: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd
sudo mkdir -p /etc/containerd
#genrate configs
containerd config default
containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep -i SystemdCgroup -B 50
systemctl status containerd
sudo systemctl restart containerd

#check required ports are open
nc 127.0.0.1 6443 -v
sudo ufw allow 6443/tcp
sudo ufw allow 2379/tcp
sudo ufw allow 2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10259/tcp
sudo ufw allow 10257/tcp
sudo ufw allow 10256/tcp
sudo ufw allow 30000:32767/tcp
sudo ufw reload
sudo ufw status verbose

#temporary disable swap
sudo swapoff -a

#4) Install kubectl kubelet kubeadm

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
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet

sudo systemctl enable --now kubelet #Enable before running kubeadm

kubeadm version

#5) Initialize control-plane node , ip address of master node, subnet all the pods pulling ip address from
kubeadm init --apiserver-advertise-address 192.168.56.21 --pod-network-cidr "10.244.0.0/16" --upload-certs

#----------------
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.56.21:6443 --token harcj5.mu0bgotpc2h3qkwo \
	--discovery-token-ca-cert-hash sha256:ff95bd13fc18d337197193ef2a1032403c8056e16a63061f04e9d7cae7f865cf 
  #

  #------------- Deploy Flannel ---------------#
 wget https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
 kubectl apply -f kube-flannel.yml
 sudo ufw allow 8472/udp 
 sudo ufw reload
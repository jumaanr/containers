#!/bin/bash

# Step 04 ) Cluster Creation : https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

# Initialize control-plane node : https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#initializing-your-control-plane-node

# we dont have multiple control plane nodes
# Choose POD Network Addon 
# --pod-network-cidr , --apiserver-advertise-address
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.56.11

#--------- Alhamdulillah: Cluster Configuration Completed------------------#

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Message from Kubernetes Configuration:
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

kubeadm join 192.168.56.11:6443 --token rfmw9v.exud3pc7riu0vnb4 \
        --discovery-token-ca-cert-hash sha256:d2e00be36a8b5e7b8034800fecd271355e6fd2af2c5d7618b5c98f64b510a0d9

kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
kubectl apply -f https://github.com/weaveworks/weave/releases/download/latest_release/weave-daemonset-k8s-1.11.yaml

kubectl get pods -A  #now it shows the containres are up and running
# What did I change : Make sure you remove ipv6 settings , if its an Azure environment makesure on NIC , IP Forwarding is enabled

# Now add weavenet address space
# If you set --cluster-cidr option in kube-proxy make sure it matches the IPALLOC_RANGE given to Weavenet
# ealier we passed : 10.244.0.0/16 as pod network, make sure to pass the same to enviorment variable of IPALLOC_RANGE
container:
  - name: weave
    env:
      -name: IPALLOC_RANGE
       value: 10.244.0.0/16

kubectl get ds -A
kubectl edit ds weave-net -n kube-system
# save above config
kubectl get pods -A

#---- on Worker Nodes -------------------#
sudo kubeadm join 192.168.56.11:6443 --token rfmw9v.exud3pc7riu0vnb4 \
        --discovery-token-ca-cert-hash sha256:d2e00be36a8b5e7b8034800fecd271355e6fd2af2c5d7618b5c98f64b510a0d9

#--- I have successfully spun an kubernetes cluster , I can -----------#

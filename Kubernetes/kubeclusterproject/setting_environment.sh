#!/bin/bash

#---------- Provision vim environment
vi ~/.vimrc
#--
set nu
set ts=2
set sw=2
set et
set ai
set pastetoggle=<F3>
#
#---------- Set the vim as default editor
sudo update-alternatives --config editor # select the vim basic as the editor in choice

$ su -
sudo vi /etc/sysctl.conf
#disable ipv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.eth0.disable_ipv6 = 1

sudo sysctl -p 
cat /proc/sys/net/ipv6/conf/all/disable_ipv6

# What did I change : Make sure you remove ipv6 settings , if its an Azure environment makesure on NIC , IP Forwarding is enable
#
sudo vim /etc/hosts
127.0.0.1 localhost
192.168.56.11 kubemaster
192.168.56.21 kubenode01
192.168.56.22 kubenode02
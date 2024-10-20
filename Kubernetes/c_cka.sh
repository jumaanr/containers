#!/bin/bash

#? This has all the cheat codes that I must keep in mind to excercise CKA Exam
# date : 25/02/24
# exam coupon code : 20KODE

#! ---------------------- Hacks-----------------------------------------------------#
# Hacks : https://kubernetes.io/docs/reference/kubectl/quick-reference/   , Search for "kubectl Quick Reference"  | https://github.com/dennyzhang/cheatsheet-kubernetes-A4

alias k='kubectl'
alias ll='ls -al'

# set the current context
kubectl config set-context $(kubectl config current-context) --namespace=mynamespace

# vi config :  vi ~/.vimrc
set smarttab
set expandtab
set shiftwidth=2
set tabstop=2
set number # sometime annoying
set pastetoggle=<F2>

# short version of it
set nu
set ts=2
set sw=2
set et
set ai
set pastetoggle=<F2>

#bash auto completion
sudo apt update
apt info bash-completion
sudo apt install bash-completion

source <(kubectl completion bash) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.
echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanently to your bash shell.

alias k=kubectl
complete -o default -F __start_kubectl k  #You can also use a shorthand alias for kubectl that also works with completion:

#TODO tmux hacks - write a few tmux hacks
ctrl + a + |   #split the terminal into two
ctrl + a + -  # split horizontally into two
apt install tmux
yum install tmux
ctrl b % # split vertically
ctrl b // # split horizontally

# kubectl cheat sheet : https://kubernetes.io/docs/reference/kubectl/quick-reference/

#TODO  copy pasting into definition files hacks :  SHIFT + V , then shift > (indent 1 tab), press 2 and then shift > for 2 tabspace
#TODO  crtl + SHIFT + V to copy paste


#!---------------------- Core Concepts----------------------------------------------#

#? --- Docker vs Containerd--- #
# CRI (Container Runtime Interface ) : Allowed any vendor to make their container runtime work with Kubernetes as long as they adhere to #* Open Container Initiative (OCI) Standards
# OCI consists of two componenets :  imagespec (specifications on how an image should be build) , runtimespec (how a container runtime should be developed)

#* crictl : A container runtime interface debugging tool , which is compatible with kubernetes
# keyword in documentation : 'Mapping from dockercli to cricli'

crictl
crictl pull busybox #pull a container image , here its a docker image
crictl images # list available images
crictl ps -a # show all running and non-running containers
crictl exec -i -t < containerID > ls # run commands in an interactive terminal with pod
crictl logs <containerID> # check logs of containers
crictl pods # crictl is aware of pods as well 

#? --- ETCD Cluster --- #


#? --- API Server --- #

# the main management component in Kubernetes : Its the only componenent that interacts with etcd datastore

#* ( Installing from Scratch )
# Installation instructions : https://github.com/shawnsong/kubernetes-handbook/blob/master/kube-apiserver/setup-kube-apiserver.md
# Binaries : https://www.downloadkubernetes.com/
# Git repo : https://github.com/kubernetes/apiserver
# official site : https://kubernetes.io/releases/  # can download the binaries at the download section at right side

wget https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/amd64/kube-apiserver


cat /etc/systemd/system/kube-apiserver.service # Api Server options can be seen here
ps -aux | grep kube-apiserver #check the running process in master node

#* Installed using kubeadm tool
cat /etc/kubernetes/manifests/kube-apiserver.yaml # configure kube apiserver options from here

# view kubeapi server in a form of pod
kubectl get pods -n kube-system


#? --- Kube Controller Manager --- #

# manages various controllers in kubernetes : process that continously monitor the state of the various components of kubernetes, ensure the system is in desired state
# node-controller : responsible of monitoring the status of nodes via kube-apiserver every 5 seconds. pod eviction timeout = 5m
# replication controller : monitor replica sets and ensure desired number of pods are running within the set
# all controllers are packaged into a single process called #? kube-controller-manager
# config reference : https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/
# download : https://kubernetes.io/releases/download/

#* Installing the hardway

wget https://dl.k8s.io/v1.29.2/bin/linux/amd64/kube-controller-manager
cat /etc/systemd/system/kube-controller-manager.service  # configure options

--node-monitor-period=5s
--node-monitor-grace-period=40s
--pod-eviction-timeout=5m0s #depricated

--controllers stringSlice Default: [*] # specify which controllers to enable , * denotes all. #TODO In case if you have any issue with availability of a certain controller, this is a good place to look at

ps -aux | grep kube-controller-manager #check the running process in master node

#* Installed using kubeadm tool
cat /etc/kubernetes/manifests/kube-controller-manager.yaml # configure kube-controller-manager in kubernetes manifests folder

#? --- Kube Scheduler --- #

# responsible for deciding which pod goes on which node, kubelet does the pod placement
# steps : filter nodes -> rank nodes
# metric based decisions : Resource requirements and limits , Taints and Tolerations , Node Selectors/Affinity

#* Installed from binaries : download binaries , install and confiure, run as a service
wget https://dl.k8s.io/v1.29.2/bin/linux/amd64/kube-scheduler
cat /etc/systemd/system/kube-scheduler.service  # can edit this

ps -aux | grep kube-scheduler # check the running process

#* Installed using kubeadm tool

cat /etc/kubernetes/manifests/kube-scheduler.yaml


#? --- kubelet --- #

# registers the node with kubernetes cluster, communicate with kube-api server and execute instructions and provide status updates of nodes

#* Installed from binaries : download binaries , install and confiure, run as a service

wget https://dl.k8s.io/v1.29.2/bin/linux/amd64/kubelet #download binaries
cat /etc/systemd/system/kubelet.service  # can edit this

ps -aux | grep kubelet # check the running process and effective options

#* Installed using kubeadm tool
#! kubeadm does not install kubelet automatically, we must install manually


#? --- kube-proxy --- #

#kube-proxy is a process runs on each node in the K8s cluster. Its job is to look for new services and every time a new service created, it creates appropriate rules on each node to forward traffic to those services to the back end pods. One way it achieves this using iptables rules. 
# kube-proxy is actually not a thing , it only lives in memory

#* Install using binaries
wget https://dl.k8s.io/v1.29.2/bin/linux/amd64/kube-proxy #download binaries and extract then and run it as a service
cat cat /etc/systemd/system/kubelet-proxy.service # configure options

#* Installing using kubeadm tool
# this deploys kube-proxy as a dameonset in each node
kubectl get pods -n kube-system
kubectl get daemonset -n kube-system

#?--- PODS ---#
#kubernetes any resource should have following basic template : https://kubernetes.io/docs/concepts/workloads/pods/
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80

#?--- Replica Set--#

# https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/
# replicaset can have pods which have been created before replicaset created by using selectors (matching metadata , labels)
kubectl get replicaset # get list of replica set
kubectl delete replicaset myapp-replicaset # delte replicaset 

kubectl explain replicaset #TODO  Tip : This would give the syntex required in definition file , displayed in terminal 

# scale a replicaset : How do we change the number of replicas in a replicaset ?
#1) update the replicaset definition file and run following
kubectl replace -f replicaset-definition.yml
#2) specify number of replicas : note using the file name as input will not result in updating number of replicase in the file : https://kubernetes.io/docs/reference/kubectl/generated/kubectl_scale/#examples
kubectl scale --replicas=6 -f replicaset-definition.yml
#3) specify number of replicas and corresponding replicaset
kubectl scale --replicas=6 replicaset myapp-replicaset


#?--- Deployments ---#
# ref : https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

kubectl get deployments
kubectl get all # get all objects created
# ref : https://kubernetes.io/docs/reference/kubectl/conventions/
#TODO !!! Certification Tip !!!
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml # create a deployment and get the output in yaml
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml
kubectl create deployment --image=nginx nginx --replicas=4 --dry-run=client -o yaml > nginx-deployment.yaml #TODO in kubernetes 1.9+ can specify replicase

#?--- Services ---#
# kubernetes services enables communication between components and withing and outside of the application
# services creates loose coupling beween micro services in application
# https://kubernetes.io/docs/concepts/services-networking/service/


# https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_service/
kubectl create service <service-type> <service-name> [--tcp=<port>] [--dry-run=server|client|none] [flags]
kubectl create service clusterip my-service --tcp=80:8080
# <service-type> : clusterip , nodeport , loadbalancer

#* Nodeport : 
# the service acts like a virtual server inside the node, inside the cluster it has its own ip address . That IP is called as the cluster ip of the service. 
# all port naming has taken in place with respective to the view of pod
# TargetPort : port on the pod , Port : port on the service , NodePort : port on the node (30,000-32,767 range of node ports)
# Port is mandatory , if no targetPort provider, it will be considered same as the port . If no nodePort provided , it will be assigned a port automatically within the range.

#* ClusterIP
# group the pods together and provides a single interface / service point to access the pods in the group 
# loosely coupled, scalable , 

kubectl get services # list the services
# the services can be reached by other pods using the clusterip or servicename.

#* Loadbalancer
# URL you give your users to access the applications ?
#only works with supported cloud platforms

#TODO Service Endpoints : Pods that service has identified that is going to direct its traffic to , based on selectors. If you see no endpoints better to check labels and selectors to identify the root cause.

#?--- Namespaces ---#


#initially following namespaces created :  default (for control plane components) , kube-system , kube-public (resources available for public)
# usecase : dev, production , test : you dont delete them by accident
# quota of resources can be allocated
# addressing db in local name spaces : mysql.connect("db-service") , addressing db in devnamespace : mysql.connect("db-service.dev.svc.cluster.local")

kubectl get pods --namespace=kube-system # get pods in kube-system namespace
kubectl get pods --all-namespaces # getting pods of all namespaces
kubectl create -f pod-definition.yaml --namespace=kube-system # create a pod in different namespace
kubectl run redis --image=redis -n=finance

# creating namespace using yaml file # ref : https://kubernetes.io/docs/tasks/administer-cluster/namespaces-walkthrough/
metadata:
  name: my-appod
  namespace: dev #! move namespace to pod definition file , so the resource will automatically create in that namepsace regardless you provide
  labels:
    app: myapp

# creating using kubectl command
kubectl create namespace <namespaceName>

# switching namespaces
kubectl config set-context $(kubectl config current-context) --namespace=mynamespace #TODO switch namespace and work on it 
$(kubectl config current-context) # identifies the current context ,then sets the namespace for the desired one for that current context
# contexts will be discussed later

# Resource Quota : Limit resourcs allocated to a certain namespace : https://kubernetes.io/docs/concepts/policy/resource-quotas/#viewing-and-setting-quotas

#? Imparative vs Declarative approaches
#TODO -------------------------------------------- Important Section ---------------------------------------------#
# Imparative commands
kubectl run --image=nginx nginx
kubectl run custom-nginx --image=nginx --port=8080 #just openining port, not exposing to a service

kubectl create deployment --image=nginx nginx
kubectl expose deployment nginx --port 80
kubectl edit deployment nginx
kubectl scale deployment nginx --replicas=5
kubectl set image deployment nginx nginx=nginx:1.18
kubectl create -f nginx.yaml
kubectl replace -f nginx.yaml
kubectl replace --force -f nginx.yamal # force delete and recreate the object , sometimes edited file can be gound under /tmp/kubectl--XXX.yaml . Then use this command to replace (Delete the pod and recreate)
kubectl delete -f nginx.yaml

# declarative commands
kubectl apply -f deployment-definition.yaml # intelligent to create, update objects (even if doesnt exist)
kubectl apply -f /path/to/config-files #specify a directory so all the objects will create at once

#TODO#  Certification Tip
#deployments
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml
kubectl create deployment nginx --image=nginx --replicas=4
kubectl scale deployment nginx --replicas=4
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > nginx-deployment.yaml

# Services
kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml #* Create a Service named redis-service of type ClusterIP to expose pod redis on port 6379, (This will automatically use the pod’s labels as selectors)
kubectl create service clusterip redis --tcp=6379:6379 --dry-run=client -o yaml #This will not use the pods labels as selectors, instead it will assume selectors as app=redis

kubectl expose pod nginx --type=NodePort --port=80 --name=nginx-service --dry-run=client -o yaml #* This create a NodePort Service and  will automatically use the pod’s labels as selectors
kubectl run httpd --image=httpd:alpine --port=80 --expose --dry-run=client -o yaml #* create a pod while create a service under same label and name

kubectl create service nodeport nginx --tcp=80:80 --node-port=30080 --dry-run=client -o yaml #(This will not use the pods labels as selectors)



#TODO  https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands  "Search as 'Kubectl Reference Docs' "

# kubectl apply --> YAML format converted to json format --> 


#!---------------------- Scheduling ------------------------------------------------#
 #?-- Manual Scheduling --#
# manual scheduling allows you to place pods on desired nodes
#* this can be done before creation of pods by adding nodeName: key under specs of the pod definition : https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodename
#-----in a pod definition file---#
spec:
  containers:
  - name: nginx
    image: nginx
  nodeName: kube-01
#--------

# if scheduler is not there , the pods will be in pending state. As a workaraound you may manually assign pods . However, the nodeNode cannot be changed once a POD created. Because its a binding object to the pod
#* solution : create a podbinding object and parse it via a POST request

apiVersion: v1
kind: Binding
metadata:
  name: nginx
target:
  apiVersion: v1
  kind: Node
  name: node02

# after convert above to a json format and send a POST request

 #?--- Labels and Selectors ---#

#In POD Definition file
#------------
metadata:
  name: pod_name
  labels:
    app: front-end
  annotations:
    buildversion: 1.134
#------------
# once specified you can perform search
kubectl get pods --selector app=App1
kubectl get pod --selector env=prod,bu=finance,tier=frontend --no-headers | wc -l # gets the count without headers

#In Deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app:App1 # we are concerned about the lables of pods

# Annotations : keep record of other details in object

#?--- Taints and Tolerations --#

# ref : https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
#applying a taint means applying a pod repellent spray on node :) | So no unwated pod going to be placed on this node #* Taints are applied on Nodes
#toleration : make a pod tolerant to a particular taints | #* Tolerations are applied on pods

kubectl taint nodes node-name key=value:taint-effect # taint effect means what happens to pods if they do not tolerate this taint
# Noschedule - pods wont be scheduled to be placed , PreferNoSchedule : may be pods will be scheduled, but less likely , Noexecute: Pods will not be scheduled and current pods will evicted with matching criteria
# example : 
kubectl taint nodes node1 key1=value1:NoSchedule #no pod will be able to schedule into node1
kubectl taint nodes node1 key1=value1:NoSchedule- # untainted using - symbox
# all of toleration should be quoted in "" 
# FACT : a taint has been set on master node when kubernetes setup to ensure no other pod deployed on master node
kubectl describe node kubemaster | grep Taint # will show the taint

#?--- Node Selectors ---#
# label the node prior to pod creation : https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/ " Assign pods nodes"
kubectl label nodes <your-node-name> <label-key>=<label-value>
kubectl get nodes --show-labels
# then specify the nodeSelector in pod definition matching the same label specified in the node

#?--- Node Affinity ---#
# ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
# ref : https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/

# First add a lable to node
kubectl label nodes <your-node-name> <label-key>=<label-value>
# then configure node affinity in pods and create pods
# Operator : In -matches the values , NotIn pods that are not matching values, Exists : whether such a label exists , 
# what if node was not lableled , what happens to pod : Thats why we have following Node Affinity types.
# available:
requiredDuringSchedulingIgnoredDuringExecution
preferredDuringSchedulingIgnoredDuringExecution 
# advanced planned:
requiredDuringSchedulingRequiedDuringExecution #* will evict any pods running on nodes since requiredDuringExecution
preferredDuringSchedulingRequiedDuringExecution

# Conclustion : Taints and Tolerations ensure node would accept only the specified pods (but does not guarentee the tolrate pods will be always placed on tainted nodes). Node affinity ensure the pods would be placed on desired nodes (But does not guarentee other pods will place on the specified nodes). So the right solution is a combination of both.

#?--- Resource Limits ---#
# Search "Resource Management for Pods and Containers" and "Assign CPU Resources to Containers and Pods" #* In POD Level
# https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/  , https://kubernetes.io/docs/tasks/configure-pod-container/assign-cpu-resource/
# 1cpu = 1 aws vCPU , 1 GCP core, 1 Azure Core , 1 Hyperthread in VMWare
# 1Gi = 1 GibiByte
# Resource Requests , Resource Limits
# CPU will not be exceeded , but Memory limits can be exceeeded and pod will be evicated if it keeps banging on the memory limit always #! "TERMINATE" due to "OOM (Out of Memory)"
# default Memory=512Mi
# ideal setting interms of CPU requests : Resource Requests are defined , Resource Limits are not defined (If there's no requests for resources , then you can consume it )
# for memory its the same , but you have to destriy the pod and recreate . Since you cannot throttle memory

#* Limit resouces in namespace level for PODs 
# https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/memory-default-namespace/
# https://kubernetes.io/docs/concepts/policy/limit-range/
# limit ranges does not effect on existing pods, but new pods will be impacted 

# usecase : limit total memory that should consumed by all the pods collectively #* This is achieved by Resource Quotas in Namespace levels
#* Important :  https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/
# https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/quota-memory-cpu-namespace/

#TODO : Special Note : You cannot edit all the properties on a pod using edit command ( look at the Forbidden parameters in the header ) , but you can edit deployments : https://kodekloud.com/topic/a-quick-note-on-editing-pods-and-deployments-2/

#?--- Daemon Sets ---#

# Daemonsets automatically spwan a copy of instance in every node, whenever a node is added to the cluster
# Daemonsets ensure a one copy of the pod always present in all nodes in the cluster
# Usecase : Monitoring Agent, Log collector , kube-proxy , weavenet 
# definition file is same as Replicaset or Deployment : https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/ 
kubectl create -f daemon-set-definition.yaml
kubectl get daemonsets
k get daemonset kube-proxy -n kube-system
kubectl describe daemonsets

# earlier kubernetes used nodeName to place pods on nodes, after kubernetes v1.12 it uses NodeAffinity rules
# if you use a deployment or deplicase template , make sure to remove replicas feild in the definition file

#?--- Static Pods ---#
# static pod: No need controlplane node, work on their own. Only can create pods in the node . No deployments etc. 
# kubelet reads the definition files in following directory and create pods
/etc/kubernetes/manifests
# kubelet take care of the pods in that directory
# can be any directory , configure as following

kubectl run --restart=Never --image=busybox static-busybox --dry-run=client -o yaml --command -- sleep 1000 > /etc/kubernetes/manifests/static-busybox.yaml
# kubelet config file location /var/lib/kubelet/ look for config.yaml there you have the options

# check this location and find the kubelet.service configuration /usr/lib/systemd/system/kubelet.service.d 
# then find the kubelet configuration file with service options


#?--- Multiple Schedulers ---#
# ref : https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/

#?--- Scheduler Events ---#

kubectl get pods --namespace=kube-system #view scheduler
# configure a scheduler of choice for a pod
schedulerName: my-customer-scheduler # This comes under spec section of pod aligned with containers (on under) : https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/
#! [ERROR] If scheduler is not configured correctly POD will remain in 'PENDING state'
# view events of kubernetes api
kubectl get events
# view logs of kubernetes scheduler
kubectl logs my-custom-scheduler --name-space=kube-system

#?--- Configure Kubernetes Scheduler Profiles ---#
# ref : https://kubernetes.io/docs/concepts/scheduling-eviction/scheduling-framework/

#!-----------------------Loggin and Monitoring -------------------------------------#

#?--- Monitoring ---#
# Metrics server in Memory monitoring solution
kubectl top node #provides CPU and memory consumption of each node
kubectl top pod #view performance metrices of k8 pods


#? --- Logging ---#
kubectl logs -f <name_ofPod> <container_name>
kubectl logs -f event-simulator-pod event-simulator # get logs of certain pod or container , -f gives live logs

#!----------------------- Application Lifecycle Management--------------------------#

#? --- Rolling Updates and Rollbacks ---#
#Deplyment strategies : Recreate (not the default) destroy all and recreate , Rolloing Update (Default)
# Update meaning :  updating application versions , version of docker container used, updating labesl, updating number of replicas

kubectl create -f deployment-definition.yaml  #create
kubectl get deployments #get available deployments
kubectl apply -f deployment-definiiton.yaml #update
kubectl edit deployment deployment/webapp-deployment # Edit a running pod to update
kubectl set image deployment/webapp-deployment nginx=nginx:1.9.1 #update
kubectl rollout history deployment/webapp-deployment # history / see the revisions and history of the deployment
kubectl rollout status deployment/webapp-deployment #status / check rollout status of the deployment
kubectl rollout undo deployment/myapp-reployment # rollback  /  #deployment will destroy the pods in new replicaset, and older ones up in the old replicaset

kubectl  create  -f  <deployment-definition.yaml>  --record  #Record option instruct Kubernetes to record the cause of change 'CHANGE-CAUSE' in rollout history
#this record option available for all the update commands as well

#? --- Configure Applications --#

#? --- ---- Configuring Command and Arguments on applications
# https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/
# style 1)
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    command:
      - "sleep"
      - "5000"
# style 2)
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    command: ["sleep","5000"]
    args: ["--color","pink"]
#---EOF

# Comparing Docker and Kubernetes Manifest files  ENTRYPOINT of Docker is equal to  command in Kubernetes manifest file. Arguments are just to run the arguments
#Providing arguments at runtime :

kubectl run nginx --image=nginx -- arg1 arg2
kubectl run nginx --image=nginx -- --color green  # start the pod using the default command , but provide arguments

kubectl run nginx --image=nginx --command -- --color green # start the pod with different command and custom arguments


#? --- ---- Configuring Environment Variables
# can be configured as a single environment variable or inject data as configmap
# define environment variables : https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/
spec:
  containers:
    - name:
      env:
        - name: color
          value: pink

# store environment variables seperately in configmaps
#?TODO--- ---- Config Map ---?#
#* Config Maps are used to store configuration data
# steps : create the config map -> inject them into the POD
# Imparative way 
kubectl create configmap \
  <config-name> --from-literal=<key><value>

kubectl create configmap \
  app-config --from-literal=APP_COLOR=blue \
            --from-literal=APP_MOD=prod

kubectl create configmap <configMapName> --from-file=<path-tofile> # data of this are read and stored under the name of the file
# declarative way : https://kubernetes.io/docs/concepts/configuration/configmap/
# how to use config map in pods : https://kubernetes.io/docs/concepts/configuration/configmap/
kubectl get configmaps
kubectl describe configmaps
# getting environment variables out of configmaps : Feed entire entirevariables from there , two methods env:  and envFrom:
spec:
  containers:
    - name:
      envFrom:
        - configMapRef
            name: app-config
# https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/   #! Gives ConfigMap usages


#TODO --- ---- Configuring Secrets ---- #
# Secret is a kubernetes object that helps to store passwords or sensitive information , after that those secrets can be injected to POD definition files seperately
# secrets can be configure in two ways : 1) Imperative way  2) Declarative way
#---- imparative way:
kubectl create secret generic <secret-name> --from-literal=<key>=<value>
kubectl create secret generic app-secret --from-literal=DB_User=mysql \
                                        -- from-literal=DB_Password=password

# using a file which had stored scecrets (Not a yaml file), lets say file name is "secret"
#---- BOF
DB_User: mysql
DB_Password: passwrd
#---- EOF
kubectl create secret generic <secret-name. --from-file=<path-to-file> # https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-config-file/
kubectl create secret generic app-secret --from-file=secret.propertiess

#--- declarative way : from a file ---#
echo -n 'mysql' | base 64 #this would encode the secret to base64, because we cannot keep plain text in secrets
# then use : https://kubernetes.io/docs/concepts/configuration/secret/#serviceaccount-token-secrets
# run kubectl create command and create secret

# --- basic commands ---#
kubectl get secrets # get the screts basic info
kubectl describe secrets # get secret names 
kubectl get secret <secretname> -o yaml # view secrets
echo -n '&^S(F)DSFD' | base64 --decode

#---- Secrets as environment variables in PODs ---#
# with env: This would pass secret keys one by one # as a single environment variable
# ref : https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#define-a-container-environment-variable-with-data-from-a-single-secret
# with envFrom: Injecting all secret at once, Configure all key-value pairs in a Secret as container environment variables
# ref : https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#configure-all-key-value-pairs-in-a-secret-as-container-environment-variables


# ---- Secrets in PODs as volumes ---#
# ref : https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#create-a-pod-that-has-access-to-the-secret-data-through-a-volume
volumes:
  - name:
    secret:
      secretName: app-secret
#
# ----- Encryption at rest : https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/

kubectl create secret generic db-secret --from-literal=DB_Host=sql01 --from-literal=DB_User=root --from-literal=DB_Password=password123

#? --- ---- Multi Container PODs --- ----#
# ref : Communicate between containers in the same pod using shared volume ; https://kubernetes.io/docs/tasks/access-application-cluster/communicate-containers-same-pod-shared-volume/
kubectl attach <pod-name> -c <container-name>  # kubectl attach, this command allows you to attach to a running container. This is useful for interacting with the container's standard input (stdin), output (stdout), and standard error (stderr) streams. It can be handy for debugging or directly interacting with processes running within your container.
kubectl exec -it <pod-name> -- /bin/sh # this connecting to container shell and we can inspect things
kubectl exec -it <pod-name> -c <container-name> -- /bin/sh #specifying the container itself , -- /bin/bash # this can be any command, here we just attach into shell, can be cat , vi command as well

#? --- ---- Init Containers --- -----#
# init containers run and complete before the actual container , can have more than one init container and they execute in the order mentioned 
# If any of the initContainers fail to complete, Kubernetes restarts the Pod repeatedly until the Init Container succeeds.
# use case : deploy code from a git repository (git clone) so the actual container can get the source code from extraction
# ref : https://kubernetes.io/docs/concepts/workloads/pods/init-containers/




#!----------------------- Cluster Maintenance --------------------------------------#

#? --- ---- OS Upgrades --- -----#
#  When you drain node, the pods are gracefully terminated from the current node and deployed on available nodes. During this time the node which is draining marked as cordoned or no schedulable. 
# No pods can be scheduled on this node until you specifically remove these restrictions. 

kubectl drain nodeName # drain all workloads
kubectl cordon nodeName # make a node unschedulable, does not evict pods or terminate from note. Only makes that node unschedulable for new pods
kubectl uncordon nodeName # make node available to schedule after maintenance

#? --- ---- Kubernetes Software Versions --- -----#
kubectl get nodes # shows the specific version of kubernetes installed
# v1.11.3 : v1 - major version , 11 - minor version , 3 - patch

#? --- ---- Cluster Upgrade Process --- -----#
# https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm='1.28.7-*' && \
sudo apt-mark hold kubeadm

sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet='1.28.7-*' kubectl='1.29.7-*' && \
sudo apt-mark hold kubelet kubectl

#? --- ---- Cluster Upgrade - kubeadm --- -----#
# ref : https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/
# ref : https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/change-package-repository/

#* upgrading master node [controlplane] : All control-plane components must be in the same version except etcd cluster

kubectl get nodes # see the version of K8s
kubectl version # check kubectl version
kubeadm version # check kubeadm version

# ensure nodes have no taints or noschedule enabled
kubeadm upgrade plan # check to what version the kubernetes components can be upgraded
kubectl drain controlplane --ignore-daemonsets

#update package repositories located at /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /

#upgrade kubeadm tool
sudo apt update
sudo apt-cache madison kubeadm # this would list the available kubeadm versions

# upgrade kubeadm : replace x in 1.29.x-* with the latest patch version
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm='1.29.0-1.1' && \
sudo apt-mark hold kubeadm

kubeadm version # verify the upgrade
kubeadm upgrade apply v1.29.0  #upgrade kubernetes version of control plane components

# upgrade kubectl : replace x in 1.29.x-* with the latest patch version
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet='1.29.0-1.1' kubectl='1.29.0-1.1' && \
sudo apt-mark hold kubelet kubectl

sudo systemctl daemon-reload
sudo systemctl restart kubelet

kubectl uncordon controlplane # make controlplane node schedulable

kubectl version # verify kubectl version
kubectl get nodes # verify kubernetes version of controlplane node
#* Upgrade worker node
kubectl drain node01 --ignore-daemonsets # drain node and make node unschedulable
ssh nodeName # ssh into node
# update the repository
#update package repositories located at /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /

#upgrade kubeadm tool , same step as control plane
kubeadm upgrade node # this would upgrade the worker node
#upgrade kubelet and kubectl after that 
# make the node schedulable again
# verify and finish the upgrade

#? --- ---- Backup and Restore --- -----#
# option 1)
# backup full kubernetes cluster
kubectl get all --all-namespaces -o yaml > all-deploy-services.yaml

# option 2)
# --data-dir=/var/lib/etcd , this is the place all the etcd data is stored
# Backup and restore from etcd cluster : https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/
ETCDCTL_API=3 etcdctl snapshot save snapshot.db # take a snapshot, you have to mention certificates
ETCDCTL_API=3 etcdctl snapshot save snapshot.db \
--endpoints=https://127.0.0.0.1:2379 \
--cacert=/etc/etcd/ca.crt
--cert=/etc/etcd/etcd
--key=/etc/etcd/etcd-server.key

ETCDCTL_API=3 etcdctl snapshot status snapshot.db # check the status of the snapshot

# Stop kube-api server before restore
service kube-apiserver stop

# restore from backup file
ETCDCTL_API=3 etcdctl snapshot restore snapshot.db --data-dir /var/lib/etcd-from-backup
# configure the etcd configuration file to use new data directory
--data-dir=/var/lib/etcd-from-backup

# restart etcd service
systemctl daemon-reload
service etcd restart

# start kube-apiserver
service kube-apiserver start

#* Backup and restore method using kubeadm implementation is mentioned in different file

#!----------------------- Security -------------------------------------------------#
#? --- TLS Certificates --#
# What certificates required for each components (server side, client side , root ca)
# Root Certificates
CA - car.crt , ca.key
# Client Certificates
admin - admin.crt , admin.key
scheduler - scheduler.crt , scheduler.key
controller-manager - controller-manager.crt , controller-manager.key
kube-proxy - kube-proxy.crt , kube-proxy.key

apiserver-kubelet-client - apiserver-kubelet-client.crt , apiserver-kubelet-client.key # kube-apiserver being a client to kubelet
apiserver-etcd-client - apiserver-etcd-client.crt , apiserver-etcd-client.key # kube-apiserver being a client to kubelet
kubelet-client - kubelet-client.crt , kubelet-client.key # kubelet being a client to kube-apiserver

# Server certificates for Servers
etcdserver - edtcdserver.crt , edctserver.key
apiserver - apiserver.crt , apiserver.key
kubelet - kubelet.crt , kubelet.key

#* ------------- How to generate a TLS certificate using openSSL ---------- #
#ref: https://kubernetes.io/docs/tasks/administer-cluster/certificates/#openssl

# Generate CA Certificate - Self Signed
openssl genrsa -out ca.key 2048 # generate keys
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr # create certificate signing request for root
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt # create self signed certificate for CA

# Generate Client Certificate for Admin User   # https://kubernetes.io/docs/tasks/administer-cluster/certificates/
openssl genrsa -out admin.key 2048
openssl req -new -key admin.key -subj "/CN=kube-admin" -out admin.csr # it does have to be kube-admin , however this is the name that kubectl client authenticate when you use kubectl command and persented in audit logs
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -out admin.crt # use ca.key to sign

openssl req -new -key admin.key -subj "/CN=kube-admin/O=system.master" -out admin.csr # when generating csr for admin user , user account to be identified as an admin user, it must be associated with SYSTEM:MASTERS group who has admin privileges

# Generate Client Certificate for kube-scheduler

      # kube-scheduler is a systom component , system:kube-scheduler
openssl req -new -key scheduler.key -subj "/CN=kube-scheduler/O=system.kube-scheduler" -out admin.csr  # CN= name of the component
      # for other components also use prefix system { system.kube-controller-manager , system.kube-proxy}

#! all components should have have ca.crt (CA root certificate ), whenever you configure a server or client , you need to specify the ca root certificate
# Generate Server Certificates (Same shit)

# etcd server certificate
openssl genrsa -out etcdserver.key 2048
openssl req -new -key etcdserver.key -subj "/CN=etcdserver" -out etcdserver.csr
openssl x509 -req -in etcdserver.csr -CA ca.crt -CAkey ca.key -out etcdserver.crt
# for etcd server, we may need additional peer certificate , since its working like as a cluster. Thats one thing

# kube-apiserver certificate
openssl genrsa -out apiserver.key 2048
openssl req -new -key apiserver.key -subj "/CN=kube-apiserver" -out apiserver.csr -config openssl.cnf
#kube-apiserver goes by many names, they are configured seperately in a config file openssl.conf in the section [alt_names]: https://kubernetes.io/docs/tasks/administer-cluster/certificates/#openssl
openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -out apiserver.crt -extensions v3_req -extfile apiserver.crt  #sign the certificte

#kubelet server - is an https apiserver runs on each node

# you need key and certificate pair in each node of the cluster
# they will be named after their respective nodes
# node01, node02 , node03
# once certificates are creted use them in a kubelet config file : https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ , https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/

# kubelet client certificates - used to connect to kube-apiserver, their name format should follow : system:node:node01 as such.
# same time they must be added to a group called SYSTEM:NODES (similar to kube-admin account )


# --- Using certificates------------
# you can use these certificate instead of username and password in a REST API call 
curtl https://kube-apiserver:6443/api/v1/pods --key admin.key --cert admin.crt --cacert ca.crt # this gives the jason output of podlist
# other method is move all of these parameter files into a kubernetes configuration file called kube-config.yaml, within that specify api-server endpoint details
# you must do this for each node in the cluster

# View certificate details 
filepath=/etc/kuberenetes/pki/server.crt
openssl x509 -in $filepath -text -noout

crictl ps -a | grep etcd # for troubleshooting
critcl logs <container-id> # for getting los
kubectl logs etcd-controlplane -n kube-system # get the logs
crictl logs --tail=2 1fb242055cff8

# Certificates API

# with certificate API, users can send send csr's directly to kubernetes through an api call
# this time when administratror receives requrest , instead of logging into master node signing the certificate each time administrator creates
# creates an kubernetes api object called CertificateSinginigRequest Object
# once created all the csros in the cluster is visible to the admin
# the csro's can be reviewd and approved using kubectl command
# ensure to put the csr in base64 encoded version

cat my.csr | base64 -w 0 # encode the csr
# ref creat csro object : https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/#create-a-certificatesigningrequest-object-to-send-to-the-kubernetes-api
# exipirationSeconds: 600 #seconds  can be also included under spec
kubectl get csr
kubectl certificate approva <certificateRequestName> # kubernetes sign the certificate with CA's private key and generates a certificate for user
kubectl get csr certificateRequestName -o yaml # view in yaml format , still the certificate in base64 version
echo "textInCertificate" | base64 --decode # this gives the certificate in plaintext format
# all the certificate related operations carried by controller manager : csr-approving , csr-signing  controllers in it
# controller amanger has two option to configure ca.crt and ca.key
# quick way to create csro : https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/#create-a-certificatesigningrequest-object-to-send-to-the-kubernetes-api

#? --- kubeconfig ----#
#purpose : helps to access multiple clusters bind  user and cluster -->  context = user+cluster with relevant certificates
# default file is located $HOME/.kube/config , copy your file and replace the default to make your one default

# specify the kubeconfig file, otherwise it would always refer to deafult file
# use a certain context configured in a non default kubeconfig file
kubectl config --kubeconfig=/root/my-kube-config use-context research
# set the current contex to a specifc context
kubectl config --kubeconfig=/root/my-kube-config current-context # view current context
kubectl config --kubeconfig=/root/my-kube-config use-context research # make current context , also you can edit the current context entry in kubeconfif file
# create a new context to an existing kubeconfig file
kubectl config --kubeconfig=/root/my-kube-config set-context  

# configure a context to a kubeconfig file
kubectl config --kubeconfig=/root/my-kube-config  set-context my-newContext --user=michelle --cluster=aws-cluster


#? ---- API Groups ---#
#ref : https://trstringer.com/Kubernetes-API-groups-resources-verbs/
# ref : https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#pod-v1-core
# type of verbs
list
get
create
delete
update
watch


#? ---- Authorization ----#
# Michanisms
# Node Authorization, Attribute based Authorization, Rolbased Access Control , Webhook - External
--authorization-mode=Node,RBAC,Webhook \\


#? ---- RBAC -----#
# you first create a role with necessary access
# then you tie that intoa rolebinding object which allows the user
kubectl create role developer --verb=list,delete,create --resource=pods
kubectl create rolebinding dev-user-binding --clusterrole=developer --user=dev-user

#? ---- ClusterRoles ---#

# -- View Full List of API Resources -- #
kubectl api-resources --namespaced=true   # View namespaced resources
kubectl api-resources --namespaced=false  # View non namespaced resources
kubectl api-resources -o wide | grep -E "^deployments" # filter api resources

kubectl get clusterroles 
kubectl get clusterrolebindings
# clusterroles are clusterwide , not part of namespace

# -- create clusterrole and bind it to a user using clusterrolebinding object
kubectl create clusterrole node-admin --verb='*' --resource=nodes --dry-run=client -o yaml
kubectl create clusterrolebinding node-admin-michelle --clusterrole=node-admin --user=michelle  --dry-run=client -o yaml

kubectl create clusterrole storage-admin --verb=list,create,get,watch --resource=storageclasses,persistentvolumes --dry-run=client -o yaml
kubectl create clusterrolebinding michell-storage-admin --clusterrole=storage-admin --user=michelle

# look for ClusterRole created in definitionfiles : '*' all verbs , supported verbs : list,get,create,update,watch : https://kubernetes.io/docs/reference/using-api/api-concepts/

#? ---- Service Accounts ---#

kubectl get serviceaccounts # get the list of SA available in current namespace
kubectl create token dashboard-sa # create a token

#? ---- Image Security ----#

# image : docker.io/libary/nginx
#         {registry}/{user/account}/{image/repository}

# -- login into private registry in docker:
docker login private-registry.io #login
docker run private-registry.io/apps/internal-app # use image from private registry to run docker container

# create a docker registry secret
kubectl create secret docker-registry registryname \
--docker-server=private-registry.io \
--docker-username=registry-user \
--docker-password=registry-password \
--docker-email=registry-user@org.com \

kubectl get secret # view secret

# add secret to deployment or pod under spec: section
# imagePullSecrets:  #ref : https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

#? ---- Security in Docker ----#
# docker run as root user by default , but capabilities of root user are restricted by docker
# can run as a different user during execution time or DOCKERFILE level
docker run --user=1010 ubuntu sleep 10000
#DOCKERFILE
FROM UBUNTU
USER 1000
# capabilities can be viewed at /usr/include/linux/capability.h 
# capabilites can be added at runtime like below
docker run --cap-add MAC_ADMIN ubuntu
# capabilities can be removed like below
docker run --cap-drop KILL ubuntu
# enable all privileges
docker run --privileged ubuntu

#? ---- Security Contexts -----#
# same docker capabilities can be provided at container level and pod level
# contianerlevel security context (user running with what capabilities) always override pod level security context
# ref : https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
# keyword : under spec: securityContext --> runASUser: , capabilities:

#? ---- Network Policies -----#

# network poilicy restric/allow certain traffic to pods
# by default pods can communicate with each other using their own virtual private network, and all type of traffic are alloweds
# if ingress rules only defined in network policy , egress wont be effected
# you can define ingress , egress rules and attach pods into the poilcies using labels and selectors (similar to network security groups)
# generic ports can be opened without specifying the target : see networkpolicy.yaml
kubectl get networkpolicies #view network policy


#!----------------------- Storage --------------------------------------------------#
# create volumes inside pod : https://kubernetes.io/docs/concepts/storage/volumes/

#? --- Persistent Volumes --- #

kubectl get persistentvolumes
# create persistent volumes : https://kubernetes.io/docs/concepts/storage/persistent-volumes/
# configure pv : https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/
# create persistent volumes using hostPath option : https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/#create-a-persistentvolume

# --- persistent volume claims ---

kubectl get persistentvolumeclaims

# claims attached as volumes inside pods : https://kubernetes.io/docs/concepts/storage/persistent-volumes/#claims-as-volumes
# https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/#create-a-persistentvolume

# --- Storage Classes ---#

#https://kubernetes.io/docs/concepts/storage/storage-classes/
kubectl get storageclasses

#!----------------------- Networking -----------------------------------------------#

#!------------------------ Installation , Configuration and Validation -------------#

#!------------------------ Troubleshooting -----------------------------------------#
kubectl describe pod <podname> # this gives the status of pod , to see what happened
# when see container failing check the logs and see what happned there
kubectl logs <podName> ] # check logs of a certain pod
kubectl logs <podName> -c <containerName> # check logs specified for a certain container in pod
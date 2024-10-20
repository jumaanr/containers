#This page for Kubernete Begineer Series

kubectl run <pod_name> #deploy an application on the cluster
kubectl cluster-info #view information about the cluster
kubectl version --short #get kubernetes version

kubectl get nodes #list all nodes that part of the cluster
kubectl describe nodes # Get entire history
kubectl get nodes -o wide #Get more information such as os version



#Reference : https://kubernetes.io/docs/concepts/  | https://kubernetes.io/docs/concepts/workloads/pods/

#create a deployment
kubectl create deployment nginx --image=nginx #create a deployment

#-----------------------PODs---------------------------------------#

#https://kubernetes.io/docs/concepts/workloads/pods/

kubectl create -f pod-definition.yml
kubectl apply -f pod-definition.yml #can apply changes to an already created pod

#Basic containers
kubectl run nginx --image nginx #specify the docker image
kubectl get pods #list the pods in a cluster
kubectl describe pod nginx # Get more information such as ip address of node, ip address of pod
kubectl describe pod -o wide # Gets medium information especially ip address and node name

kubectl run --image=nginx nginx --dry-run=client -oyaml  #Get the output in YAML formal
kubectl get pods -o name | wc -l  # get the pod names and retrive the exact count

kubectl delete pod <podname> # delete a certain pod
kubectl edit <pod_name> #however this only changes the running config

#configure resource limits : https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#example-1
# something you will never read : https://kubernetes.io/docs/tasks/configure-pod-container/assign-cpu-resource/


#----------------------- Replication Controller and Replica Sets --------------------#
# ref : https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/

kubectl get replicationcontroller
kubectl get replicaset
kubectl describe replicaset #shows more information selectors,namespace
# Replica Set , apiVersion: apps/v1
# Major difference is-   selecter: (Selector definition helps to indentify what pods falls under it, why ? It has the capability of managing pods thats not part of replicaset creation)
# can be skillped as well. We can specify based on what critedia it selects. thats why we use 'matchLabels' selector

kubectl create -f replicaset-definition.yml
kubectl delete replicaset # delete replicaset

#Lets say we updated the number of replicas 
kubectl replace -f replicaset-definition.yml  #Method 1
kubectl scale --replicas=6 -f replicaset-definition.yml #Metho 2  , (Only changes the running config)
kubectl scale --replicas=6 replicaset myapp-replicaset #Method 3 , Here you have specified the type and the name of replicaset (Only changes the running config)

#This also worked for me : 
kubectl get replicaset -o name
kubectl scale --replicas=2 replicaset.apps/new-replica-set

# edit running configuration
kubectl edit replicaset myreplicaset #It opens up the running config of replicaset in text editor, this is a temporary file created by kubernetes. This method also can be used to scale down the replicas
#You can also run Method # described above to scale down

#Trick 1: Getting a backup of existing deployment  
kubectl get replicaset <replicasetName> -o yaml > replicasetName-definition.yaml 
#Trick 2: Getting the template of yaml file , if you dont know
kubectl explain replicaset


#---------------------- Labels and Selectors ----------------------------------------#

# Use labels when creating pods, so under selector we can specify lables that replicaset should concern about
kubectl run [NAME] --image=[IMAGE_NAME]:[TAG]  --labels=key1=value1,key2=value2

#---------------------- Deployments --------------------------#
# Has the ability to create replicasets
# ref : https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

kubectl create -f deployment-definition.yml
kubectl get deployments

#following objects are part of deployment
kubectl get replicasets
kubectl get pods

kubectl get all # to see all created kuberenetes objects

#************* Create a Deployment************
kubectl create deployment myDeployment --image=image_name --replicas=no --dry-run=client -o yaml > deployment-definition.yaml

#------------------ Updates and Rollbacks in Deployment-----------------#

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

#----------------------Kubernetes Services ---------------------------------------------------------------------------#


# https://kubernetes.io/docs/concepts/services-networking/service/

# NodePort :
#----------------------YAML------------------------------------------
spec:
    type: NodePort
    ports:
        - targetPort: 80 #port of pod
          port: 80 #port of service object (mandotory), if you dont provide the targetport it will be assumed to be the same as port
          nodePort: 30008 #port of the node , in the valid range (if dont provided, a free port from the range automatically allocated)

          #note port is an array , so you have multiple ports opened within a single service
    selecter:
        app: myapp
        type: front-end
    #above is how we link the pods with service, selected by selector
#-----------------------------------------------------------------------
kubectl create -f service-definition.yaml
kubectl get services
curl <ipAddress>:30008
#kubernetes spans service across all the nodes in the cluster, so you can access application using IP of any node   NodeX:30008
#no need to do any thing, its automatic

# ClusterIP (Default Type) :
metadata:
    name: back-end
spec:
    type: ClusterIP
    ports:
     -  targetPort: 80 #where back end exposed (container side)
        port: 80 # where service exposed
    selecter:
        app: myapp
        type:   back-end
    #This links the service to the pods

#Load Balancer : What URL you will give your users to access the application, you cant give different diferrent nodes ip address
spec:
    type: LoadBalancer
    ports:
     -  targetPort: 80
        port: 80
        nodePort: 30008
#Options:  
# 1) Can have our own linux box as a LB
# 2) Native Cloud LB from Azure, AWS, GCP
# If you have you dont deploy on CLoud it will act as a nordPort instead

kubectl create service clusterip [SERVICE_NAME] --tcp=[PORT]:[TARGET_PORT]
kubectl create service nodeport [SERVICE_NAME] --tcp=[PORT]:[TARGET_PORT]
kubectl create service loadbalancer [SERVICE_NAME] --tcp=[PORT]:[TARGET_PORT]

kubectl get services

# Check for Enpoints using describe to troubleshoot , see how many enpoints are attached



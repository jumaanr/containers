#-------------------------[ Docker Installation ]-----------------------------#
#Setting up docker in Linux machine , here its an Ubuntu VM
# https://docs.docker.com/engine/install/ubuntu/

#System Pre-requisties
cat /etc/*release*
#un-install any older versions if exists
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
#update apt package index
sudo apt-get update

#Three methods of installation
# 1) Install using apt repository
# 2) Install using package
# 3) Install using a convinience script

# Install using a convinience script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh --dry-run #you can remove the dry-run argument to run actually

#check the version of docker
docker --version
docker version #with more information

#check using docker run imgsrc: https://hub.docker.com/r/docker/whalesay
sudo docker run docker/whalesay cowsay Hello-World!

#-------------------------[ Docker Commands Basic ]-----------------------------#


#------ Docker Run Commands---------

docker run nginx    #runs an docker nginx container, if the image is not available locally it will pull the image from dockerhub, same image will be reused
docker run  --name webapp nginx:1.14-alpine  # define a custom name for container

docker run ubuntu:17.10  # Appending a tag, where we run a different version of Ubuntu than running the default
docker run redis:4.0  #specify a Tag which is a specific version of redis image, if not specified the default tag = latest applied

#Run a container in a remote docker host/engine
docker -H=10.123.2.1:2375 run nginx #using IP 
#TCP port 2375 is commonly used for communication with the Docker Remote API. 
#The Docker Remote API provides an interface for interacting with the Docker daemon (Docker Engine) programmatically over HTTP.
docker -H=remote-docker-engine:2375 run nginx #using hostname 

docker ps           #list all the running containers and basic information about them, container ID and name is shown
docker ps -a        # show all running, stopped, terminated(Exited) containers
docker ps -aq       #list only container ids

docker stop containerIDorName # you can give container ID or name. to stop a running contianer, can give multiple container name/ids with seperated by space
docker stop $(docker ps -aq) # stop all containers at once, exit code 0 means killed naturally and exit code > 0 means killed forcibly

docker rm containerIDorName #remove container to reclaim disk space , you can specify multiple containers with IDs
docker rm container1 container2
docker rm containerIDorName # remove stopped or exited contianers permanently, should print the name back
docker rm $(docker ps -aq) #remove all containers at once

# Containers are not meant to run operating system, containers are meant to run specific task or process i.e webserver , db server
# Once the task completes it exits , therefore following container stops immediately goes to exited state
docker run ubuntu

#-------- Command Execution ----------#
docker run ubuntu sleep 5 # Execute a command when we run a container
docker run ubuntu cat /etc/*release* # Here executes a command with multiple aruments

docker exec ContainerName cat /etc/hosts # Execute a command in a running container
docker exec -it containerID /bin/bash #Attach a terminal to already running container

docker run -it centos bash # automatically log into docker container as it runs

#---- Attach & Detach ---------------
docker run kodekloud/simple-webapp  #container is a simple webapp, this is in attached mode. It means the console is attached to the standard out of the docker container
#the convention here user_id/repositoryName
docker run -d kodekloud/simple-webapp # run the container in detached mode, if image is un official kodekloud/simple-webapp it will be like this
docker attach a043d # re attach the console to container , give container ID (first few charrachters alone)

#-------- Images------------------#
docker images       # see a list of images
docker rmi ImageName # remove an image that no longer plan to use, ensure no containers are using that image. Stop, delete dependant instances
docker rmi $(docker images -aq) #remove all images
docker pull ImageName # Only download/pull the image

docker history ImageName #show how the image is build and sizes

docker image prune -a #remove all obsolete image expect for lates
docker image ls #see the list of images


#--------- Docker Run -------------#

# Run-STDIN interactively input standard input
docker run -it kodekloud/simple-prompt-docker  
#if the application run in the container requires sort of an input from user , you can bring interactive mode above and get the stanadard input attached to terminal

# Port Mapping 
docker run -p <externalPort_hostEnd>:<internalPort_containerEnd>  kodekloud/webapp # externalPort_hostEnd this is port users access calling docker host's IP address
docker run -p 80:5000 kodekloud/webapp #you cannot map to the same port more than once

#Volume Mapping
docker run -v <directory_dockerHost>:<directory_insideContainer>  mysql #This method helps to persist data
docker run -v /opt/datadir:/var/lib/mysql mysql 

#---- Get comprehensive information about a container--------
docker inspect <containerName|containerID> # Returns all details in json format , state, mounts, config and network settings
docker inspect blissful_hopper

docker logs <containerName|containerID> #get logs of a container that ran in background
docker logs blissful_hopper

#--------- Building Custom Docker Images using Docker File -------------#
docker build Dockerfile -t mummshad/my-custom-app:lite  #build your own image using Dockerfile , -t for tag name | this will create an image locally in your system : here tage is 'lite'
docker build Dockerfile2 -t mummshad/my-custom-app2
docker build . -t mumshad/my-simple-webapp #build from the docker file available in current location. Here also we tag it . 

docker build . #see the various steps involved and the result of each task
$ docker build -t webapp-color . #At the end of the command, we used the "." (dot) symbol which indicates for the current directory, so you need to run this command from within the directory that has the Dockerfile.

docker history mumshad/my-custom-app # To see the docker build information, how the layered architecture has been formed

docker login #login to your user account before you publish
docker push mummshad/my-custom-app  #make it available in public docker registry, <accountName>/<ImageName>
#Alpine images are in general smaller images


docker run -p 8282:8080 webapp-color
docker run python:3.6 cat /etc/*release*

#------- ENV variables--------#
docker run -e APP_COLOR=blue simple-webapp-color
# you can pass a value to an environment vairable like above
docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag

# to check if a docker image configured with an enviornment varaible
docker inspect blissful_hopper # under config section you can see 'ENV' configured
docker inspect containerName_id | grep -A 5 "Env" # search for environment variables and values in 5 consecutive lines

#----Commands vs Entrypoints-#
CMD ["command","param1"] #Inside the Dockerfile makesure to enter command as of a jason array
ENTRYPOINT["sleep"]  # the command line parameter get appended , in CMD the commandline parameters overridden

#configuring a default value
ENTRYPOINT["sleep"]
CMD["5"]  #so the default value of CMD get appended to the entrypoint . At the start it will kick sleep 5 , unless specified #* Important to have these specified in JSON format

# overriding entry point value

docker  run  --entry-point   sleep2.0   ubuntu-sleeper 10 #overried the command at startup, here ENTRYPOINT ["sleep"] but we want to change it during runtime as sleep2.0
#so the final command will be :  sleep2.0 10

#---------- Docker Compose -----------------------
docker compose up #create and start containers
docker-compose up -d  #run on detach modes

#Installing Docker Compose : https://docs.docker.com/compose/
# Docker compose commands : https://docs.docker.com/engine/reference/commandline/compose/

sudo apt update
sudo apt install curl
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version


#----------Linking two contianers together----------

$ docker run -d --name=vote -p 5000:80   --link  nameofContainer:nameofHost   voting-app  #

#link is a command line option which can be used to link two containers together

#----------- Docker Engine : Resources and Namespaces----------------#
docker run --cpu=.5 ubuntu #not more than 50% of the CPU used by contianer at a given time.
docker run --memory=100m ubuntu # not more than 50% memory of the System Physical Memory used by container at a given time.

#----------- Docker Storage -----------------------#
#Createa a volume, creates a folder under /var/lib/docker/volumes directory of the docker host
docker volume create data_volume
# mount the docker volume inside the docker container , syntax -v <hostEndDirectory>:<ContainerEndDirectory>
docker run -v data_volume:/var/lib/mysql mysql
#Even if you didn’t create data_volume  volume before running the container , docker will automatically create a volume with the specified name and mount it to the container.  This called volume mounting
docker run -v /data/mysql:/var/lib/mysql mysql # mount a volume from different location other than /var/lib/docker/volumes, aka bind mounting
#More comprehensive bind mounting,preferred way
docker run --mount type=bind,source=/data/mysql,target=/var/lib/mysql mysql

# Docker use storage drivers to enable layered architecture

#Question :What directory under /var/lib/docker are the files related to the container alpine-3 image stored?
#Answer: The directory name is the same as the container id.
#Here an example binding of mysql database instance , where /opt/data directory is at host end
docker run -v /opt/data:/var/lib/mysql -d --name=mysql-db -e MYSQL_ROOT_PASSWORD=db_pass123 mysql

#------------ Docker Network -----------------------#
#docker has 3 networks : bridge (private internal netwok created by docker, require port mapping to expose , IP Range: 172.17.X.X), none (isolated), host(associate container with host network, host and docker isolated removed)
docker run ubuntu  #this will be created in bridged network by default
docker run --name alpine-2 --network=none alpine #container created in none network.
docker run --name alpine-2 --network=host alpine #container created in host network.

#create custom isolated network
docker network  create  --driver bridge  --subnet  182.18.0.0/16   custom-isolated-network
docker network create --driver=bridge --subnet=182.18.0.1/24 --gateway=182.18.0.1 wp-mysql-network

#Check docker network details
docker inspect container_name/id #check network details of a container
docker network ls # check network details of docker
docker network inspect bridge # find more details about a certain network. here bridge=<network_name> , replace it with network name
#containers can reach/resolve each other using their names, it has embedded DNS. Docker has a built-in DNS server that helps the containers to resolve each other.
#Docker user network name spaces that creates a sperate name space for each container.
#Then it use Virtual Ethernet Pairs to connect containers together.

#Examples
docker run -d -e MYSQL_ROOT_PASSWORD=db_pass123 --name=mysql-db --network wp-mysql-network mysql:5.6 
docker run --network=wp-mysql-network -e DB_Host=mysql-db -e DB_Password=db_pass123 -p 38080:8080 --name webapp --link mysql-db:mysql-db -d kodekloud/simple-webapp-mysql

#--------- Docker Registry---------#
# image: docker.io/nginx/nginx
# docker.io/nginx/nginx
# <registry>/<userAccount>/<image_repository>

#Example : gcr.io/kubernetes-e2e-test-images/dnsutils    : This is from Kubernetes Registry

#login to private registry first always before pushing
docker login private-registry.io
#run the container
docker run private-registry.io/apps/internal-app

#-------Deploying on-premise private registry

#Docker 'registry' is an application that available as a docker image
docker run -d -p 5000:5000 --name registry registry:2
#Example:
docker run -d -p 5000:5000 --restart always --name my-registry registry:2

#how do you push the image to the registry
#first tag the image
docker image tag my-image localhost:5000/my-image # tag the image with private registry url in it, since its running on same docker host we have used localhost. Otherwise IP address
#push the image to local registry
docker push localhost:5000/my-image  #here localhost:5000
#pull the image within my network/ localhost
docker pull localhost:5000/my-image
#if accessing another host
docker pull 192.168.56.100:5000/my-image

#Check private registry repository
curl -X GET localhost:5000/v2/_catalog

# remove all the dangling images we have locally.
docker image prune -a #remove alll images without at least one container associated
docker image ls #check available images

#------------- Docker Command Cheat Sheet Completed-------#
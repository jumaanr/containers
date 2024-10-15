#application stack order
# start with data layer
docker run -d --name=redis redis
docker run -d --name=db postgres

#application services
docker run --name=vote -p 5000:80 voting-app
docker run --name=result -p 5001:80 result-app
docker run --name=worker worker

#But we havent actually linked them together

#asking webapplication to use redis instance, this adds an entry to the /etc/hosts file of voting-app container adding hostname=redis with the internal ip of the redis container
docker run --name=vote -p 5000:80 --link redis:redis voting-app
docker run --name=result -p 5001:80 --link db:db result-app
docker run --name=worker --link db:db --link redis:redis worker
# please note that using links this way has been deprecated
# lets create a docker compose file out of this

#Voting App without docker compose
#-------------------------------------------------------
#1) clone repository
git clone https://github.com/dockersamples/example-voting-app.git
#2) build voting app image
docker build . -t voting-app
#3) deploy redis container
docker run -d --name=redis redis
#4) deploy voting app container
docker run -d -p 5000:80 --link redis:redis voting-app
#5) deploy postrgress database
docker run -d --name=db postgres:9.4
docker run -e POSTGRES_HOST_AUTH_METHOD=trust --name=db postgres:9.4
#6) deploy worker image
sudo docker build . -t worker-app #sudo used as I didnt have sufficient permissions in Azure vm
#7) check the newly created app image
sudo docker images
#8) deploy the worker docker app
sudo docker run -d --link redis:redis --link db:db worker-app
#9) build the result app image
sudo docker build . -t result-app
#10) deploy result-app image
sudo docker run -d -p 5001:80 --link db:db result-app
#11) check the webapplication voting app in docker host
IPAddress:5000
#12) check the result app
IPAddress:5001


#Installing Docker Compose : https://docs.docker.com/compose/
# Docker compose commands : https://docs.docker.com/engine/reference/commandline/compose/

sudo apt update
sudo apt install curl
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version




#Lab CI/CD
#--------------------
jenkins/jenkins #this is the official image
docker run jenkins/jenkins
#Jenkins image : https://www.jenkins.io/blog/2018/12/10/the-official-Docker-image/ , https://hub.docker.com/r/jenkins/jenkins/ , https://github.com/jenkinsci/docker/blob/master/README.md
# Lets explore and browse to jenkins webserver and UI
docker ps #observer ports
docker inspect jenkinscont_id #get the ip address of the container

# try it using internal IP http://172.17.0.2:8080 , Lets map it to external port
# an admin user has been created and password can be found in the output of docker run command
docker run -p 8080:8080 jenkins/jenkins
docker run -p 8080:8080 -v /root/my-jenkins-data:/var/jenkins_home -u root jenkins/jenkins #specify the user requires permission to access
#more instructions are here : https://github.com/jenkinsci/docker/blob/master/README.md
docker run -p 8080:8080 -p 50000:50000 --restart=on-failure -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts-jdk11
docker run -d -v jenkins_home:/var/jenkins_home -p 8080:8080 -p 50000:50000 --restart=on-failure jenkins/jenkins:lts-jdk11
#install suggested plugins
#configure user profile
#free style project , create a test job
#-----------completed--------#
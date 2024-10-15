
#<Instruction> <Argument>

#OS is Ubuntu,must start FROM instruction
FROM Ubuntu

# Update apt repo, RUN instruct docker to run a particular command on those base images
RUN apt-get update

#Install dependencies using pip
RUN apt-get install python
RUN apt get install python-pip
  
#Install Python dependencies using pip
RUN pip install flask
RUN pip install flask-mysql

#Copy source code to /opt folder, COPY copies files from the local system to docker image | "." denotes current location
COPY . /opt/source-code

#The WORKDIR instruction in a Dockerfile sets the current working directory for subsequent instructions in the Dockerfile.
WORKDIR /app

#Run the webserver using the "flask" command
#ENTRYPOINT allows to specify a command that will be run when the image run as a container
ENTRYPOINT FLASK_APP=/opt/source-code/app.py flask run

#Execute a command, you can also have following syntax
# CMD command param1  ,  example : CMD sleep 5
CMD [ "command","parameter" ]



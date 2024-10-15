# Webapp code and instructions : https://github.com/mmumshad/simple-webapp-flask

# spwan a docker container with ubuntu image and connect to its terminal
docker run -it ubuntu bash
# update apt-get packages
apt-get update
#install dependancies
apt-get install -y python python-setuptools python-dev build-essential python-pip python-mysqldb
#Install Python Flask dependency
pip install flask
pip install flask-mysql
#deploy the source code, copy and save it
cat > /opt/app.py
#Start the webserver, move to your working directory to application location
FLASK_APP=app.py flask run --host=0.0.0.0
#check the webapp inside dockrehost
http://<IP>:5000                            => Welcome
http://<IP>:5000/how%20are%20you            => I am good, how about you?
# Lets consolidate this into a docker container image


docker images
# azurecontainer
Created to commit and save the work with regards to Azure DevOps and Container Platforms


The voting app consist of following architectural requirements
	- Voting app takes the voting count ( Built in Python)
	- Pass it to in-memory DB ( Redis)
	- Then worker app process the date and count the votes 
	- counted votes saved in persistent database called 'db' built in PostgreSQL
    - Finally the results are output from result-app which is built in NodeJs

Referenced project : https://github.com/dockersamples/example-voting-app

![Voting Application High Level architecture](VotingApplication/votingapplication.jpg)


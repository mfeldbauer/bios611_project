#Breast Cancer Analysis Project

##What does this project contain?

##How to build the docker image:
Command to build the docker image (run from directory containing Dockerfile):
``docker build . -t project-env``

Command to run docker image (Rstudio):
``docker run --rm -d -v <insert path to project folder or $(pwd) if you're in the directory already>:/home/rstudio -p 8787:8787 -e PASSWORD=<insert a password> -t project-env``

Note that you should enter a password of your choosing after ``PASSWORD=``

Example:
``docker run --rm -d -v /mnt/c/Users/mifel/Documents/UNC/Classes/BIOS611_data_sci/bios611_project:/home/rstudio -p 8787:8787 -e PASSWORD=pw -t project-env

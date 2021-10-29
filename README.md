# Breast Cancer Analysis Project

## What does this project contain?

## How to build the docker image:
Command to build the docker image (run from directory containing Dockerfile):

``docker build . -t project-env``

Command to run docker image (Rstudio):

``docker run --rm -d -v <insert path to project folder or "$(pwd)" if you're in the directory already>:/home/rstudio -p 8787:8787 -p 8080:8080 -e PASSWORD=<insert a password> -t project-env``

Note that you should enter a password of your choosing after ``PASSWORD=``
Note that you need the quotes around $(pwd) if your path has spaces. They are not necessary if the path does not contain spaces. 

Example:

``docker run --rm -d -v /mnt/c/Users/mifel/Documents/UNC/Classes/BIOS611_data_sci/bios611_project:/home/rstudio -p 8787:8787 -p 8080:8080 -e PASSWORD=pw -t project-env``

##How to run the shiny app:
``interactive_plots.R`` creates a shiny app that allows you to explore patient data based on breast cancer subtype. You can choose which data to display on the x-axis (age at diagnosis, whether the patient is living or has died, and survival length in months) and which subtype to investigate.

In order to run the shiny app, build the docker image and connect to Rstudio using the above commands. Then run this command in your Rstudio terminal:

``make shiny_app``

Once it runs, open a new browser tab and go to ``localhost:8080``. You will be able to choose the subtype and which data you want to visualize. 

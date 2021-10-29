# Breast Cancer Analysis Project

## What does this project contain?
This project contains analysis of the METABRIC (Nature 2012 & Nat Commun 2016) breast cancer dataset downloaded from kaggle: https://www.kaggle.com/raghadalharbi/breast-cancer-gene-expression-profiles-metabric. The dataset includes patient and clinical data for 1,904 patients. mRNA expression levels are included as z-scores and gene mutation data is also included.

## How to build the docker image:
Command to build the docker image (run from directory containing Dockerfile):

``docker build . -t project-env``

Command to run docker image (Rstudio):

``docker run --rm -d -v <insert path to project folder or "$(pwd)" if you're in the directory already>:/home/rstudio/project -p 8787:8787 -p 8080:8080 -e PASSWORD=<insert a password> -t project-env``

Note that you should enter a password of your choosing after ``PASSWORD=``.
Also note that you need the quotes around $(pwd) if your path has spaces. They are not necessary if the path does not contain spaces. 

Example:

``docker run --rm -d -v /mnt/c/Users/mifel/Documents/UNC/Classes/BIOS611_data_sci/bios611_project:/home/rstudio/project -p 8787:8787 -p 8080:8080 -e PASSWORD=pw -t project-env``

After running this command, open your browser and go to ``localhost:8787``. Sign into Rstudio with the username: rstudio and the password you inserted into the docker command.
## In order to run analysis:
Build the Docker image and connect to Rstudio using the above docker command. Once you log into Rstudio, change into the project directory by clicking on "project" in the files pane. Then click the "more" gear in that same pane and click "Set As Working Directory".

## How to make the figures:
Go to the Rstudio terminal and run

``make figures/mrna_expression_heatmap_most_mutated_genes.png``

## How to run the shiny app containing an interactive expression heatmap:
``expression_heatmap_interactive.R`` creates a shiny app containing an interactive heatmap of mRNA expression. You can choose areas on the map that you want to look at further and the supmap will be displayed.

In order to run this shiny app, run this command in your Rstudio terminal:

``make shiny_heatmap`` 

Once it runs, open a new browser tab and go to ``localhost:8080``. You will be able to choose the subtype and which data you want to visualize.

To close the connection, close the ``localhost:8080`` browser tab and click the stop sign in the upper corner of the Rstudio terminal. This is a necessary step if you want to run the other shiny app.

## How to run the shiny app to explore patient data:
``interactive_plots.R`` creates a shiny app that allows you to explore patient data based on breast cancer subtype. You can choose which data to display on the x-axis (age at diagnosis, whether the patient is living or has died, and survival length in months) and which subtype to investigate.

In order to run the shiny app, run this command in your Rstudio terminal:

``make shiny_app``

Once it runs, open a new browser tab and go to ``localhost:8080``. You will be able to choose the subtype and which data you want to visualize. 

To close the connection, close the ``localhost:8080`` browser tab and click the stop sign in the upper corner of the Rstudio terminal. This is a necessary step if you want to run the other shiny app.

# Breast Cancer Analysis Project

## What does this project contain?
This project contains analysis of the METABRIC (Nature 2012 & Nat Commun 2016) breast cancer dataset downloaded from kaggle: https://www.kaggle.com/raghadalharbi/breast-cancer-gene-expression-profiles-metabric. The dataset includes patient and clinical data for 1,904 patients. mRNA expression levels are included as z-scores and gene mutation data is also included. Initial analysis focused on this dataset which included a smaller subset of genes, chosen by the individual who uploaded the set to kaggle. However, later analysis switches to the complete dataset which can be found on cBioPortal: https://www.cbioportal.org/study/summary?id=brca_metabric. This set includes all genes included in the METABRIC study (over 24,000). 

Note that the large dataset from cBioPortal is too large to upload to GitHub. I have automated it's download from cBioPortal in the bash script ```obtain_large_dataset.sh```. The download of the dataset will occur automatically when building the report or making any target that uses it. Recently, those in charge of maintaining the data on cBioPortal changed the name of the files. To combat this, the bash script is choosing the file with a size of over 500,000 KB because that should be the expression file that I use in my analysis.

## How to build the docker image:
Command to build the docker image (run from directory containing Dockerfile):

```
docker build . -t project-env
```

Command to run docker image (Rstudio):

```
docker run --rm \
-d \
-v <insert path to project folder or "$(pwd)" if you're in the directory already>:/home/rstudio/project \
-p 8787:8787 -p 8080:8080 \
-e PASSWORD=<insert a password> \
-t project-env
```

Note that you should enter a password of your choosing after ```PASSWORD=```.
Also note that you need the quotes around $(pwd) if your path has spaces. They are not necessary if the path does not contain spaces. 

Example:

```
docker run --rm \
-d \
-v /mnt/c/Users/mifel/Documents/UNC/Classes/BIOS611_data_sci/bios611_project:/home/rstudio/project \
-p 8787:8787 -p 8080:8080 \
-e PASSWORD=pw \
-t project-env
```

After running this command, open your browser and go to ```localhost:8787```. Sign into Rstudio with the username: rstudio and the password you inserted into the docker command.
## In order to run analysis:
Build the Docker image and connect to Rstudio using the above docker command. Once you log into Rstudio, change into the project directory by clicking on "project" in the files pane. Then click the "more" gear in that same pane and click "Set As Working Directory".

## How to make the report:
Go to the Rstudio terminal and run

```
make report.pdf
```

Note: due to the inclusion of the large dataset, the report takes a while to build.

## How to run the shiny app containing an interactive expression heatmap:
```expression_heatmap_interactive.R``` creates a shiny app containing an interactive heatmap of mRNA expression. You can choose areas on the map that you want to look at further and the submap will be displayed. Note that these expression data come from the inital data set downloaded from kaggle (NOT the larger data set downloaded from cBioPortal.

In order to run this shiny app, run this command in your Rstudio terminal:

```
make shiny_heatmap
``` 

Once it runs, open a new browser tab and go to ```localhost:8080```. You will be able to zoom in on areas of the map which will produce a sub-heatmap.

To close the connection, close the ```localhost:8080``` browser tab and click the stop sign in the upper corner of the Rstudio terminal. This is a necessary step if you want to run the other shiny apps.

## How to run the shiny apps to explore patient data:
```interactive_plots.R``` creates a shiny app that allows you to explore patient data based on breast cancer subtype. Note that these data come from the inital dataset downloaded from kaggle. The clinical data for the larger data set from cBioPortal might be slightly different. ```large_set_clinical_data_plots.R``` creates a shiny app to explore the larger dataset's clinical data. You can choose which data to display on the x-axis (age at diagnosis, whether the patient is living or has died, survival length in months, whether the patient's tumor recurred, and time to recurrence) and which subtype to investigate. 

In order to run the shiny app, run this command in your Rstudio terminal:

```make shiny_app```

In order to run the shiny app exploring the clinical data corresponding to the larger dataset, run this command in your Rstudio terminal:

```make shiny_app_large_set ```

Once either of these apps runs (note that you can only run one at a time), open a new browser tab and go to ```localhost:8080```. You will be able to choose the subtype and which data you want to visualize. 

To close the connection, close the ```localhost:8080``` browser tab and click the stop sign in the upper corner of the Rstudio terminal. This is a necessary step if you want to run the interactive shiny heatmap.

FROM rocker/verse
WORKDIR .
RUN R -e "install.packages(\"tidyverse\"); if(!library(tidyverse, logical.return=T)) quit(status=10)"
RUN R -e "install.packages(\"circlize\"); if(!library(circlize, logical.return=T)) quit(status=10)"
RUN R -e "install.packages(\"fastcluster\"); if(!library(fastcluster, logical.return=T)) quit(status=10)"
RUN R -e "install.packages(\"devtools\"); if(!library(devtools, logical.return=T)) quit(status=10)"
RUN R -e "install.packages(\"shiny\"); if(!library(shiny, logical.return=T)) quit(status=10)"
RUN R -e "install.packages(\"plotly\"); if(!library(plotly, logical.return=T)) quit(status=10)"
RUN R -e "install.packages(\"janitor\"); if(!library(janitor, logical.return=T)) quit(status=10)"
RUN R -e "devtools::install_github('jokergoo/ComplexHeatmap')"
RUN R -e "devtools::install_github('jokergoo/InteractiveComplexHeatmap')"

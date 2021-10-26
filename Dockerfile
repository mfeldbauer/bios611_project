FROM rocker/verse
WORKDIR .
RUN R -e "install.packages(\"tidyverse\"); if(!library(tidyverse, logical.return=T)) quit(status=10)"
RUN R -e "install.packages(\"circlize\"); if(!library(circlize, logical.return=T)) quit(status=10)"

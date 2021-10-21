FROM rocker/verse
WORKDIR .
RUN R -e "install.packages(\"tidyverse\"); if(!library(tidyverse, logical.return=T)) quit(status=10)"

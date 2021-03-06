FROM rocker/verse
WORKDIR .
RUN R -e "install.packages(\"tidyverse\"); if(!library(tidyverse, logical.return=T)) quit(status=22)"
RUN R -e "install.packages(\"circlize\"); if(!library(circlize, logical.return=T)) quit(status=22)"
RUN R -e "install.packages(\"fastcluster\"); if(!library(fastcluster, logical.return=T)) quit(status=22)"
RUN R -e "install.packages(\"devtools\"); if(!library(devtools, logical.return=T)) quit(status=22)"
RUN R -e "install.packages(\"shiny\"); if(!library(shiny, logical.return=T)) quit(status=22)"
RUN R -e "install.packages(\"plotly\"); if(!library(plotly, logical.return=T)) quit(status=22)"
RUN R -e "install.packages(\"janitor\"); if(!library(janitor, logical.return=T)) quit(status=22)"
RUN R -e "devtools::install_github('jokergoo/ComplexHeatmap')"
RUN R -e "devtools::install_github('jokergoo/InteractiveComplexHeatmap')"
RUN R -e "install.packages('tinytex'); if(!library(tinytex, logical.return=T)) quit(status=22); tinytex::install_tinytex(dir=\"/opt/tinytex\")"
RUN R -e "install.packages('ggplot2'); if(!library(ggplot2, logical.return=T)) quit(status=22)"
RUN R -e "install.packages('GGally'); if(!library(GGally, logical.return=T)) quit(status=22)"
RUN R -e "install.packages('gbm'); if(!library(gbm, logical.return=T)) quit(status=22)"
RUN R -e "install.packages('survival'); if(!library(survival, logical.return=T)) quit(status=22)"
RUN R -e "install.packages('survminer'); if(!library(survminer, logical.return=T)) quit(status=22)"

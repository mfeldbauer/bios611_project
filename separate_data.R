#separate_data.R
#Purpose: imports source data, cleans and splits it into 3 different data sets,
#     and exports them to csv files
library(tidyverse)

METABRIC_data<-read.csv("source_data/METABRIC_RNA_Mutation.csv", header=TRUE, sep=",", fill=TRUE)
METABRIC_data<-METABRIC_data %>% mutate_all(na_if, "")

patient_and_clinical_data<-METABRIC_data[, which(colnames(METABRIC_data)=="patient_id"):which(colnames(METABRIC_data)=="death_from_cancer")]
expression_data<-METABRIC_data[, which(colnames(METABRIC_data)=="brca1"):which(colnames(METABRIC_data)=="ugt2b7")]
mutation_data<-METABRIC_data[, which(colnames(METABRIC_data)=="pik3ca_mut"): which(colnames(METABRIC_data)=="siah1_mut")]

expression_data<-cbind(METABRIC_data$patient_id, expression_data) %>% rename("patient_id" = "METABRIC_data$patient_id")
mutation_data<-cbind(METABRIC_data$patient_id, mutation_data) %>% rename("patient_id" = "METABRIC_data$patient_id")

write_csv(patient_and_clinical_data, "derived_data/patient_and_clinical_data.csv")
write_csv(expression_data, "derived_data/expression_data.csv")
write_csv(mutation_data, "derived_data/mutation_data.csv")
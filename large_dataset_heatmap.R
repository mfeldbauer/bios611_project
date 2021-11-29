#large_dataset_heatmap.R
#Purpose: make a heatmap using the PAM50 genes that were included in the expression matrix
library(ComplexHeatmap)
library(tidyverse)
library(circlize)
library(fastcluster)

expression_data<-read.csv("derived_data/highly_exp_and_mut_genes_matrix_from_large_set.csv", header=T, sep=",", row.names=1)
pam50_genes<-read.csv("source_data/pam50_genes.csv", header=TRUE)
expression_data<-expression_data[rownames(expression_data) %in% pam50_genes$gene,]
expression_matrix<-as.matrix(expression_data) #genes are rows and samples are columns

patient_info<-read.table("source_data/clinical_patient_info.txt", header=TRUE, sep="\t", fill=TRUE) %>% 
  select(c("PATIENT_ID", "CLAUDIN_SUBTYPE"))
sample_info<-read.table("source_data/clinical_sample_info.txt", header=TRUE, sep="\t", fill=TRUE) %>% 
  select(c("PATIENT_ID", "ER_STATUS", "HER2_STATUS"))

clinical_info<-merge(patient_info, sample_info, by="PATIENT_ID")
clinical_info<-clinical_info[clinical_info$PATIENT_ID %in% colnames(expression_matrix),]

expression_matrix<-expression_matrix[, colnames(expression_matrix) %in% clinical_info$PATIENT_ID]

table(clinical_info$CLAUDIN_SUBTYPE)
table(clinical_info$ER_STATUS)
table(clinical_info$HER2_STATUS)

col_fun<-colorRamp2(c(5,8,10), colorRampPalette(c("dodgerblue", "white", "red2"))(3))

map_annotation_samples<-HeatmapAnnotation(subtype=clinical_info$CLAUDIN_SUBTYPE, er_status=clinical_info$ER_STATUS,
                                          her2_status=clinical_info$HER2_STATUS, col=list(
                                            subtype=c("Basal"="red", "Her2"="hotpink","LumA"="darkblue","LumB"="skyblue","Normal"="green", "claudin-low"="darkorange", NC="black"),
                                            er_status=c("Negative"="#1AFF1A", "Positive"="#4B0092"),
                                            her2_status=c("Negative"="#1AFF1A", "Positive"="#4B0092")
                                          ))
clustering_func = function(x) fastcluster::hclust(dist(x))

png("figures/large_set_highly_var_and_exp_heatmap.png")

Heatmap(expression_matrix, name="mRNA Expression",
           col=col_fun,
           cluster_rows=clustering_func,
           cluster_columns=clustering_func,
           border=TRUE,
           show_column_names=FALSE,
           column_title="mRNA Expression",
           top_annotation = map_annotation_samples)

dev.off()

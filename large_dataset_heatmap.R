#large_dataset_heatmap.R
#Purpose: make a heatmap using the PAM50 genes that were included in the expression matrix
library(ComplexHeatmap)
library(tidyverse)
library(circlize)
library(fastcluster)

expression_data<-read.csv("derived_data/highly_exp_and_var_genes_matrix_from_large_set.csv", header=T, sep=",", row.names=1)
pam50_genes<-read.csv("source_data/pam50_genes.csv", header=TRUE)
expression_data<-expression_data[rownames(expression_data) %in% pam50_genes$gene,] #trim expression data
pam50_genes<-pam50_genes[pam50_genes$gene %in% rownames(expression_data),] #in turn, trim the gene list

#Quick check to see if the data are median centered - they're not
summary(t(expression_data["ESR1", ]))
summary(t(expression_data["ERBB2",]))

#Function to median center the GENES
medianCtr<-function(x){
  annAll <- dimnames(x)
  medians <- apply(x,1,median,na.rm=T)
  x <- t(scale(t(x),center=medians,scale=F))
  dimnames(x) <- annAll
  return(x)
}

expression_data.medctr<-as.data.frame(medianCtr(expression_data))
#Quick check again - they're all good (median should be zero)
summary(t(expression_data.medctr["ESR1", ]))
summary(t(expression_data.medctr["ERBB2",]))

expression_matrix<-as.matrix(expression_data.medctr) #genes are rows and samples are columns
expression_matrix<-expression_matrix[pam50_genes$gene,] #reorder matrix so the genes are in the same order as the genes in the annotation

#check to make sure they match up (should all be true)
summary(rownames(expression_matrix)==pam50_genes$gene)

patient_info<-read.table("source_data/clinical_patient_info.txt", header=TRUE, sep="\t", fill=TRUE) %>% 
  select(c("PATIENT_ID", "CLAUDIN_SUBTYPE"))
sample_info<-read.table("source_data/clinical_sample_info.txt", header=TRUE, sep="\t", fill=TRUE) %>% 
  select(c("PATIENT_ID", "ER_STATUS", "HER2_STATUS"))

clinical_info<-merge(patient_info, sample_info, by="PATIENT_ID")
clinical_info<-clinical_info[clinical_info$PATIENT_ID %in% colnames(expression_matrix),]

expression_matrix<-expression_matrix[, colnames(expression_matrix) %in% clinical_info$PATIENT_ID]
expression_matrix<-expression_matrix[, clinical_info$PATIENT_ID] #reorder so the samples are in the same order as the annotation

#check to make sure they match up
summary(colnames(expression_matrix) == clinical_info$PATIENT_ID)

table(clinical_info$CLAUDIN_SUBTYPE)
table(clinical_info$ER_STATUS)
table(clinical_info$HER2_STATUS)

col_fun<-colorRamp2(c(-2,0,2), colorRampPalette(c("dodgerblue", "white", "red2"))(3))

map_annotation_samples<-HeatmapAnnotation(Subtype=clinical_info$CLAUDIN_SUBTYPE, "ER status"=clinical_info$ER_STATUS,
                                          "HER2 status"=clinical_info$HER2_STATUS, col=list(
                                            Subtype=c("Basal"="red", "Her2"="hotpink","LumA"="darkblue","LumB"="skyblue","Normal"="green", "claudin-low"="darkorange", NC="black"),
                                            "ER status"=c("Negative"="#0C7BDC", "Positive"="#FFC20A"),
                                            "HER2 status"=c("Negative"="#0C7BDC", "Positive"="#FFC20A")
                                          ))

row_annotation_genes<-rowAnnotation("Cell type"=pam50_genes$cell_type, col=list(
  "Cell type"=c("actin"="#9F0162", "apoptosis inhibitor"="#01197E", "mitosis"="#1F78B4", "regulatory"="#00FCCF",
              "growth factor"="#B15928", "hormone receptor"="#E1BE6A", "keratin"="#FFB2FD",
              "transcription factor"="red", "catalysis"="forestgreen", "cell cycle"="#814CB2", 
              "other"="#808080")))

clustering_func = function(x) fastcluster::hclust(dist(x))

pdf("figures/large_set_pam50genes_heatmap.pdf")

Heatmap(expression_matrix, name="mRNA Expression",
           col=col_fun,
           cluster_rows=clustering_func,
           cluster_columns=clustering_func,
           border=TRUE,
           show_column_names=FALSE,
           column_title="mRNA Expression",
           top_annotation = map_annotation_samples,
           left_annotation = row_annotation_genes,
           row_names_gp = gpar(fontsize=8))

dev.off()

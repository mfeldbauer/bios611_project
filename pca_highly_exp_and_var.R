#Take in large expression matrix (highly variable and expressed genes)
#Perform PCA

library(tidyverse)
library(ggplot2)
library(GGally)
select<-dplyr::select

expression_data<-read.csv("derived_data/highly_exp_and_mut_genes_matrix_from_large_set.csv", header=T, sep=",", row.names=1, fill=TRUE)
expression_data<-na.omit(expression_data)

#Function to mean center the samples
meanCtr<-function(x){
  apply(x, 2, function(y) y - mean(y))
}

expression_data<-meanCtr(expression_data)
expression_data<-as.data.frame(t(expression_data))
expression_data<-rownames_to_column(expression_data, "PATIENT_ID")

patient_info<-read.table("source_data/clinical_patient_info.txt", header=TRUE, sep="\t", fill=TRUE) %>% 
  select(c("PATIENT_ID", "CLAUDIN_SUBTYPE"))
patient_info<-patient_info[patient_info$PATIENT_ID %in% expression_data$PATIENT_ID,]

expression_data<-merge(patient_info, expression_data, by="PATIENT_ID")

pca<-prcomp(expression_data[3:ncol(expression_data)])
summary(pca)$importance[,1:8] 
nine_dims<-pca$x %>% as_tibble() %>% select(PC1, PC2, PC3, PC4, PC5, PC6, PC7, PC8, PC9)

PCi<-data.frame(pca$x, Subtype=expression_data$CLAUDIN_SUBTYPE)
pc1_var<-summary(pca)$importance[,1][2]*100
pc2_var<-summary(pca)$importance[,2][2]*100

pdf("figures/pca_plot_high_exp_and_var.pdf", width=7, height=5)
ggplot(PCi, aes(x=PC1, y=PC2, col=Subtype)) + geom_point(alpha=0.5) +
  scale_color_manual(values=c("Basal"="red", "Her2"="hotpink","LumA"="darkblue",
                              "LumB"="skyblue","Normal"="green", "claudin-low"="darkorange", NC="black")) +
  xlab(str_c("PC1 (", pc1_var, "%)")) + ylab(str_c("PC2 (", pc2_var, "%)"))

dev.off()

pdf("figures/multiplot_five_pcs.pdf", width=9, height=7)
ggpairs(PCi, columns = 1:5, ggplot2::aes(colour=Subtype))
dev.off()

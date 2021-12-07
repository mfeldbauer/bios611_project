#heatmap_most_mutated_genes.R
#Purpose: make a heatmap using only the most mutated genes
library(ComplexHeatmap)
library(tidyverse)
library(circlize)
library(fastcluster)

mutation_data<-read.csv("derived_data/mutation_data.csv", header=T,sep=",", row.names=1)

#Figure out which genes are mutatated the most
num_muts<-as.data.frame(colSums(mutation_data != "0")) %>% rename("muts"="colSums(mutation_data != \"0\")")
#grab the genes that have more than 100 mutation instances
muts_greater100<-rownames(num_muts)[which(num_muts$muts>100)]
muts_greater100<-str_remove_all(muts_greater100, "_mut")

expression_data<-read.csv("derived_data/expression_data.csv", header=TRUE, sep=",", row.names=1)
expression_data<-expression_data[, colnames(expression_data) %in% muts_greater100]
expression_matrix<-as.matrix(t(expression_data)) #transpose so that genes are rows and samples are columns

sample_annotation<-read.csv("derived_data/patient_and_clinical_data.csv", header=TRUE,sep=",", row.names=1) %>%
  select(c("age_at_diagnosis",
           "cancer_type_detailed","pam50_._claudin.low_subtype",
           "er_status_measured_by_ihc","her2_status"))

#The order of the samples in the expression matrix should be the same as the annotation file
#(should all be true)
summary(colnames(expression_matrix)==rownames(sample_annotation))

col_fun<-colorRamp2(c(-2,0,2), colorRampPalette(c("dodgerblue", "white", "red2"))(3))

map_annotation_samples<-HeatmapAnnotation(subtype=sample_annotation$pam50_._claudin.low_subtype, er_status=sample_annotation$er_status_measured_by_ihc,
                                          her2_status=sample_annotation$her2_status, col=list(
                                            subtype=c("Basal"="red", "Her2"="hotpink","LumA"="darkblue","LumB"="skyblue","Normal"="green", "claudin-low"="darkorange", NC="black"),
                                            er_status=c("Negative"="#1AFF1A", "Positive"="#4B0092"),
                                            her2_status=c("Negative"="#1AFF1A", "Positive"="#4B0092")
                                          ))
clustering_func = function(x) fastcluster::hclust(dist(x))

png("figures/mrna_expression_heatmap_most_mutated_genes.png")

Heatmap(expression_matrix, name="mRNA Expression",
           col=col_fun,
           cluster_rows=clustering_func,
           cluster_columns=clustering_func,
           border=TRUE,
           show_column_names=FALSE,
           column_title="mRNA Expression",
           top_annotation = map_annotation_samples)

dev.off()

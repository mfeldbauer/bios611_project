#expression_heatmap.R
#Purpose: to make a heatmap of the mRNA expression
library(ComplexHeatmap)
library(tidyverse)
library(circlize)
library(fastcluster)
library(InteractiveComplexHeatmap)

expression_data<-read.csv("derived_data/expression_data.csv", header=TRUE, sep=",", row.names=1)
expression_matrix<-as.matrix(t(expression_data)) #transpose so that genes are rows and samples are columns


sample_annotation<-read.csv("derived_data/patient_and_clinical_data.csv", header=TRUE,sep=",", row.names=1) %>%
  select(c("age_at_diagnosis",
         "cancer_type_detailed","pam50_._claudin.low_subtype",
         "er_status_measured_by_ihc","her2_status"))

table(sample_annotation$pam50_._claudin.low_subtype)
table(sample_annotation$er_status_measured_by_ihc)
table(sample_annotation$her2_status)

col_fun<-colorRamp2(c(-2,0,2), colorRampPalette(c("dodgerblue", "white", "red2"))(3))

map_annotation_samples<-HeatmapAnnotation(subtype=sample_annotation$pam50_._claudin.low_subtype, er_status=sample_annotation$er_status_measured_by_ihc,
                                          her2_status=sample_annotation$her2_status, col=list(
                                            subtype=c("Basal"="red", "Her2"="hotpink","LumA"="darkblue","LumB"="skyblue","Normal"="green", "claudin-low"="darkorange", NC="black"),
                                            er_status=c("Negative"="#1AFF1A", "Positive"="#4B0092"),
                                            her2_status=c("Negative"="#1AFF1A", "Positive"="#4B0092")
                                          ))

clustering_func = function(x) fastcluster::hclust(dist(x))

#pdf("figures/mrna_expression_heatmap_all_genes.pdf")

ht=Heatmap(expression_matrix, name="mRNA Expression",
        col=col_fun,
        cluster_rows=clustering_func,
        cluster_columns=clustering_func,
        border=TRUE,
        show_column_names=TRUE,
        column_title="mRNA Expression",
        top_annotation = map_annotation_samples)

htShiny(ht)

#dev.off()

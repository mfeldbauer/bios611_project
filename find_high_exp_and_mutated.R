#Given expression and mutation data, find the genes that are highly expressed and 
# have the most mutations
#Output the expression matrix with just those genes to be used in a heatmap

library(tidyverse)

#Figure out which genes are differentially expressed
expression_data<-read.csv("derived_data/expression_data.csv", header=TRUE, sep=",", row.names=1)
exp_data_transposed<-expression_data %>% t()

#Looking at median expression across genes (1 for rows)
exp_data.med<-apply(exp_data_transposed, 1, median, na.rm=TRUE)

#ID highly expressed
summary(exp_data.med>0)
highly_expressed_genes<-names(exp_data.med)[exp_data.med>0]

#Figure out which genes are mutatated the most (from the ones that are highly expressed)
mutation_data<-read.csv("derived_data/mutation_data.csv", header=T,sep=",", row.names=1)
mutation_data<-mutation_data[, str_remove_all(colnames(mutation_data), "_mut") %in% highly_expressed_genes]
num_muts<-as.data.frame(colSums(mutation_data != "0")) %>% rename("muts"="colSums(mutation_data != \"0\")")

#grab the genes that have more than the mean mutation instances
most_muts<-rownames(num_muts)[which(num_muts$muts>median(num_muts$muts))] 
most_muts<-str_remove_all(most_muts, "_mut")

expression_data<-expression_data[, colnames(expression_data) %in% most_muts] %>%
  rownames_to_column(var="patient_id")

write_csv(expression_data, "derived_data/highly_exp_and_mut_genes_matrix.csv")


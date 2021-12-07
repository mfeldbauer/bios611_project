#Given the expression data, find the genes that are highly expressed and 
#         variable and subset the matrix based on that
#Output the expression matrix with cleaned data and fewer genes

library(tidyverse)

#Read in dataset and prepare the data
pam50_genes<-read.csv("source_data/pam50_genes.csv", header=TRUE, sep=",")

expression_data<-read.table("source_data/data_mrna_expression.txt", sep="\t", header=TRUE, fill=TRUE) %>% 
  select(-Entrez_Gene_Id)
expression_data<-expression_data[!duplicated(expression_data[,"Hugo_Symbol"]),]
rownames(expression_data)<-expression_data[,1]
expression_data<-expression_data %>% select(-Hugo_Symbol) %>% as.matrix()

expression_data[1:3, 1:5]

#Figure out which genes are differentially expressed
exp_data.med<-apply(expression_data, 1, median, na.rm=TRUE)
exp_data.sd<-apply(expression_data, 1, sd, na.rm=TRUE)

exp_cutoff<- 7.5
sd_cutoff<- 0.5

summary((exp_data.med>exp_cutoff & exp_data.sd>sd_cutoff) | rownames(expression_data) %in% pam50_genes$gene)

pdf("figures/highly_exp_and_variable_genes_large_dataset.pdf")
plot(exp_data.med, exp_data.sd, pch=".", ylab="Standard Deviation",
     xlab="Median Expression per Gene", main="Expression and Variance of all Genes",
     col=ifelse((exp_data.med>(exp_cutoff - 0.001) & exp_data.sd>(sd_cutoff - 0.001)) | 
                  rownames(expression_data) %in% pam50_genes$gene, "red", "black"))
legend("topright", legend=c("High Expression & Variance"), col=c("red"), pch=20)
abline(v=exp_cutoff, h=sd_cutoff)
dev.off()

expression_data<-cbind(expression_data, exp_data.med)
expression_data<-cbind(expression_data, exp_data.sd)
expression_data<-subset(expression_data, (expression_data[, "exp_data.med"] > exp_cutoff & 
                                            expression_data[, "exp_data.sd"] > sd_cutoff) | 
                          rownames(expression_data) %in% pam50_genes$gene)

#drop the median expression and standard deviation columns bc they're not samples
expression_data<-expression_data[, -1905]
expression_data<-expression_data[, -1905] #you removed med in the step above so sd became 1905
write.table(expression_data, "derived_data/highly_exp_and_var_genes_matrix_from_large_set.csv", sep=",", col.names=NA)

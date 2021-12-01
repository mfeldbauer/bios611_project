#glm_large_set.R
#Creates a general linear model to predict death from subtype

library(tidyverse)

patient_info<-read.table("source_data/clinical_patient_info.txt", header=TRUE, sep="\t", fill=TRUE)
expression_data<-read.csv("derived_data/highly_exp_and_mut_genes_matrix_from_large_set.csv", header=T, sep=",", row.names=1, fill=TRUE)

patient_info<-patient_info[patient_info$PATIENT_ID %in% colnames(expression_data),]
nc_rows<-which(patient_info$CLAUDIN_SUBTYPE=="NC")
patient_info<-patient_info[-nc_rows,]

select<-dplyr::select
death_table<-patient_info %>% dplyr::select("PATIENT_ID", "OS_MONTHS", "OS_STATUS", 
                                     "CLAUDIN_SUBTYPE", "VITAL_STATUS")
other_death_rows<-which(death_table$VITAL_STATUS=="Died of Other Causes")
death_table<-death_table[-other_death_rows,] #exclude the ones who died of other causes
table(death_table$VITAL_STATUS)

death_table<-death_table %>% rename("death_occurred"="VITAL_STATUS")
death_table$death_occurred[death_table$death_occurred=="Living"]<-0 #0 because the event (death) did NOT occur
death_table$death_occurred[death_table$death_occurred=="Died of Disease"]<-1 #1 because the event (death) DID occur

death_data_tt<-death_table %>% group_by(death_occurred) %>% mutate(train=runif(length(death_occurred))<0.5) %>% ungroup()
test<-death_data_tt %>% filter(train==FALSE) %>% select(-train)
train<-death_data_tt %>% filter(train==TRUE) %>% select(-train)

train$death_occurred<-as.numeric(train$death_occurred)
test$death_occurred<-as.numeric(test$death_occurred)

model<-glm(death_occurred ~ CLAUDIN_SUBTYPE, data=train, family="binomial")

prob<-predict(model, newdata=test, type="response")
#test_ex<-test %>% mutate(death_prob_predict=1*(prob>0.5))
test_ex<-test %>% mutate(death_prob_predict=predict(model, newdata=test, type="response"))

rate<-function(a){
  sum(a)/length(a);
}

maprbind<-function(f,l){
  do.call(rbind, Map(f,l));
}

roc<-maprbind(function(thresh){
  ltest<-test_ex %>% mutate(death_pred=1*(death_prob_predict>=thresh)) %>%
    mutate(correct=death_pred == death_occurred);
  tp<-ltest %>% filter(ltest$death_occurred==1) %>% pull(correct) %>% rate();
  fp<-ltest %>% filter(ltest$death_occurred==0) %>% pull(correct) %>% `!`() %>% rate();
  tibble(threshold=thresh, true_positive=tp, false_positive=fp);
}, seq(from=0, to=1, length.out=10)) %>% arrange(false_positive, true_positive)

pdf("figures/roc_curve_glm.pdf", width=7, height=5)
ggplot(roc, aes(false_positive, true_positive)) + geom_line()
dev.off()

summary(model)



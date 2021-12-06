#Create a gbm to predict death from subtype

library(tidyverse)
library(gbm)
library(ggplot2)
select<-dplyr::select

patient_info<-read.table("source_data/clinical_patient_info.txt", header=TRUE, sep="\t", fill=TRUE)
expression_data<-read.csv("derived_data/highly_exp_and_mut_genes_matrix_from_large_set.csv", header=T, sep=",", row.names=1, fill=TRUE)

patient_info<-patient_info[patient_info$PATIENT_ID %in% colnames(expression_data),]
nc_rows<-which(patient_info$CLAUDIN_SUBTYPE=="NC")
patient_info<-patient_info[-nc_rows,]

death_table<-patient_info %>% dplyr::select("PATIENT_ID", "VITAL_STATUS")
other_death_rows<-which(death_table$VITAL_STATUS=="Died of Other Causes")
death_table<-death_table[-other_death_rows,] #exclude the ones who died of other causes
table(death_table$VITAL_STATUS)

death_table<-death_table %>% rename("death_occurred"="VITAL_STATUS")
death_table$death_occurred[death_table$death_occurred=="Living"]<-0 #0 because the event (death) did NOT occur
death_table$death_occurred[death_table$death_occurred=="Died of Disease"]<-1 #1 because the event (death) DID occur

subtypes<-patient_info %>% select("PATIENT_ID", "CLAUDIN_SUBTYPE")
subtypes_wide<-subtypes %>% distinct() %>% mutate(dummy=1) %>% 
  pivot_wider(id_cols="PATIENT_ID", names_from="CLAUDIN_SUBTYPE", values_from="dummy",values_fill=list(dummy=0))
subtypes_wide<-subtypes_wide %>% rename("claudin_low"="claudin-low")

data<-subtypes_wide %>% inner_join(death_table, by="PATIENT_ID")
data$death_occurred <- as.numeric(data$death_occurred)
data<-na.omit(data)

explanatory<-data %>% select(-PATIENT_ID, -death_occurred) %>% names()
formula<-as.formula(sprintf("death_occurred ~ %s", paste(explanatory, collapse=" + ")))
tts<-runif(nrow(data)) < 0.5

train<-data %>% filter(tts)
test<-data %>% filter(!tts)
model<-gbm(formula, data=train)
prob<-predict(model, newdata=test, type="response")  
test_ex<-test %>% mutate(death_occ_pred=1*(prob>0.5))

rates_tally<-test_ex %>% group_by(death_occurred, death_occ_pred) %>% tally()

TN<-rates_tally$n[which(rates_tally$death_occurred==0 & rates_tally$death_occ_pred==0)]

FP<-rates_tally$n[which(rates_tally$death_occurred==0 & rates_tally$death_occ_pred==1)]

FN<-rates_tally$n[which(rates_tally$death_occurred==1 & rates_tally$death_occ_pred==0)]

TP<-rates_tally$n[which(rates_tally$death_occurred==1 & rates_tally$death_occ_pred==1)]

#TPR = TP/TP+FN
true_pos_rate<-TP/(TP+FN)
print(str_c("True positive rate: ", true_pos_rate))

#TNR = TN/TN+FP
true_neg_rate<-TN/(TN+FP)
print(str_c("True negative rate: ", true_neg_rate))

#FPR = FP/FP+TN
false_pos_rate<-FP/(FP+TN)
print(str_c("False positive rate: ", false_pos_rate))

#FNR = FN/FN+TP
false_neg_rate<-FN/(FN+TP)
print(str_c("False negative rate: ", false_neg_rate))

accuracy<-(TP+TN)/(TN+TP+FN+FP)
print(str_c("Accuracy: ", accuracy))
precision<-TP/(TP+FP)
print(str_c("Precision: ", precision))
recall<-TP/(TP+FN)
print(str_c("Recall: ", recall))
f1_score<-precision*recall/(precision+recall)
print(str_c("f1_score: ", f1_score))

rate<-function(a){
  sum(a)/length(a);
}

maprbind<-function(f,l){
  do.call(rbind, Map(f,l));
}

roc<-maprbind(function(thresh){
  ltest<-test_ex %>% mutate(death_pred=1*(death_occ_pred>=thresh)) %>% 
    mutate(correct=death_pred==death_occurred)
  tp<-ltest %>% filter(ltest$death_occurred==1) %>% pull(correct) %>% rate()
  fp<-ltest %>% filter(ltest$death_occurred==0) %>% pull(correct) %>% `!`() %>% rate()
  tibble(threshold=thresh, true_positive=tp, false_positive=fp)
}, seq(from=0, to=1, length.out=10)) %>% arrange(false_positive, true_positive)

ggplot(roc, aes(false_positive, true_positive)) + geom_line()

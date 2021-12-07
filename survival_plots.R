#Create KM survival curves given our clinical data

library(tidyverse)
library(survival)
library(survminer)

patient_info<-read.table("source_data/clinical_patient_info.txt", header=TRUE, sep="\t", fill=TRUE)
expression_data<-read.csv("derived_data/highly_exp_and_var_genes_matrix_from_large_set.csv", header=T, sep=",", row.names=1, fill=TRUE)

patient_info<-patient_info[patient_info$PATIENT_ID %in% colnames(expression_data),]
nc_rows<-which(patient_info$CLAUDIN_SUBTYPE=="NC")
patient_info<-patient_info[-nc_rows,]

############################## overall survival ##################################
#survival status - 1 if event (death due to disease) is observed 
#0 if censored (ie death of other causes or living)

km_table_survival<-patient_info %>% select("PATIENT_ID", "CLAUDIN_SUBTYPE", "OS_MONTHS", "VITAL_STATUS") %>%
  rename("Subtype"="CLAUDIN_SUBTYPE")
km_table_survival$OS_YEARS<-km_table_survival$OS_MONTHS/12

km_table_survival$status<-km_table_survival$VITAL_STATUS
km_table_survival$status[km_table_survival$status=="Died of Disease"]<-1
km_table_survival$status[km_table_survival$status=="Died of Other Causes"]<-0
km_table_survival$status[km_table_survival$status=="Living"]<-0
km_table_survival$status<-as.numeric(km_table_survival$status)
km_table_survival<-na.omit(km_table_survival)

fit_survival<-survfit(Surv(km_table_survival$OS_YEARS, km_table_survival$status) ~ Subtype, data=km_table_survival)

pdf("figures/km_plot_overall_survival.pdf", width=10, height=8, onefile=FALSE)
ggsurvplot(fit_survival, data=km_table_survival, risk.table=TRUE,
           palette=c("red", "darkorange", "hotpink", "darkblue", "skyblue", "green"),
           legend.title="Subtype", xlab="Time (years)", title="Overall Survival",
           legend.labs=c("Basal", "Claudin-low", "HER2", "Luminal A", "Luminal B", "Normal")
)
dev.off()

############################## disease-free survival ##################################
#event status - 1 if event (recurrence) is observed 
#0 if censored (ie not recurred or death)

km_table_recur<-patient_info %>% select("PATIENT_ID", "CLAUDIN_SUBTYPE", "VITAL_STATUS", "RFS_STATUS", "RFS_MONTHS") %>%
  rename("Subtype"="CLAUDIN_SUBTYPE")
km_table_recur$RFS_YEARS<-km_table_recur$RFS_MONTHS/12

km_table_recur$status<-km_table_recur$RFS_STATUS
km_table_recur$status[km_table_recur$status=="1:Recurred"]<-1
km_table_recur$status[km_table_recur$status=="0:Not Recurred"]<-0
km_table_recur$status<-as.numeric(km_table_recur$status)
km_table_recur<-na.omit(km_table_recur)

fit_recur<-survfit(Surv(km_table_recur$RFS_YEARS, km_table_recur$status) ~ Subtype, data=km_table_recur)

pdf("figures/km_plot_overall_recur.pdf", width=10, height=8, onefile=FALSE)
ggsurvplot(fit_recur, data=km_table_recur, risk.table=TRUE,
           palette=c("red", "darkorange", "hotpink", "darkblue", "skyblue", "green"),
           legend.title="Subtype", xlab="Time (years)", title="Recurrence-Free Survival",
           legend.labs=c("Basal", "Claudin-low", "HER2", "Luminal A", "Luminal B", "Normal")
)
dev.off()


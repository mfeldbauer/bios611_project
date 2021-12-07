#Make a few plots showing clinical data

library(tidyverse)
library(janitor)
library(plotly)
select<-dplyr::select

patient_info<-read.table("source_data/clinical_patient_info.txt", header=TRUE, sep="\t", fill=TRUE) %>%
  select(c("PATIENT_ID","AGE_AT_DIAGNOSIS", "OS_MONTHS", "OS_STATUS", "CLAUDIN_SUBTYPE", "VITAL_STATUS",
           "RFS_STATUS", "RFS_MONTHS"))
sample_info<-read.table("source_data/clinical_sample_info.txt", header=TRUE, sep="\t", fill=TRUE) %>%
  select("PATIENT_ID", "ER_STATUS", "HER2_STATUS")

clinical_info<-merge(patient_info, sample_info, by="PATIENT_ID")
expression_data<-read.csv("derived_data/highly_exp_and_mut_genes_matrix_from_large_set.csv", header=T, sep=",", row.names=1)
clinical_info<-clinical_info[clinical_info$PATIENT_ID %in% colnames(expression_data),]

######################## ages #########################
ages<-clinical_info %>% select("CLAUDIN_SUBTYPE", "AGE_AT_DIAGNOSIS")
age_factor<-cut(clinical_info$AGE_AT_DIAGNOSIS, pretty(clinical_info$AGE_AT_DIAGNOSIS, 8))
labs<-levels(age_factor)

ages$age_group<-cut(clinical_info$AGE_AT_DIAGNOSIS, 
                    pretty(clinical_info$AGE_AT_DIAGNOSIS, 8), labels=labs)
ages_wide<-tabyl(ages, age_group, CLAUDIN_SUBTYPE)

#pdf("figures/age_at_diagnosis_by_type.pdf")
basal<-plot_ly(ages_wide, x=~ages_wide$age_group, y=~ages_wide$Basal, type="bar", name="Basal") %>%
  layout(yaxis=list(range=c(0,200)))
claudin_low<-plot_ly(ages_wide, x=~ages_wide$age_group, y=~ages_wide$`claudin-low`, type="bar", name="Claudin Low") %>%
  layout(yaxis=list(range=c(0,200)))
her2<-plot_ly(ages_wide, x=~ages_wide$age_group, y=~ages_wide$Her2, type="bar", name="HER2") %>%
  layout(yaxis=list(range=c(0,200)))
lumA<-plot_ly(ages_wide, x=~ages_wide$age_group, y=~ages_wide$LumA, type="bar", name="Luminal A") %>%
  layout(yaxis=list(range=c(0,200)))
lumB<-plot_ly(ages_wide, x=~ages_wide$age_group, y=~ages_wide$LumB, type="bar", name="Luminal B") %>%
  layout(yaxis=list(range=c(0,200)))
normal<-plot_ly(ages_wide, x=~ages_wide$age_group, y=~ages_wide$Normal, type="bar", name="Normal") %>%
  layout(yaxis=list(range=c(0,200)))
fig<-subplot(basal, claudin_low, her2, lumA, lumB, normal, nrows=3) %>% layout(title="Age at Diagnosis")

fig


################## survival in months #################
survival<-clinical_info %>% select("CLAUDIN_SUBTYPE", "OS_MONTHS", "VITAL_STATUS")
other_death_rows<-which(survival$VITAL_STATUS=="Died of Other Causes")
survival<-survival[-other_death_rows,] #exclude the ones who died of other causes
table(survival$VITAL_STATUS)

survival_factor<-cut(survival$OS_MONTHS, pretty(survival$OS_MONTHS, 8))
labs_survival<-levels(survival_factor)

survival$survival_group<-cut(survival$OS_MONTHS, pretty(survival$OS_MONTHS, 8), labels=labs_survival)
survival_wide<-tabyl(survival, survival_group, CLAUDIN_SUBTYPE)

max_count_survival<-110

basal_os_months<-plot_ly(survival_wide, x=~survival_wide$survival_group, y=~survival_wide$Basal, type="bar", name="Basal") %>%
  layout(yaxis=list(range=c(0,max_count_survival)))
claudin_low_os_months<-plot_ly(survival_wide, x=~survival_wide$survival_group, y=~survival_wide$`claudin-low`, type="bar", name="Claudin Low") %>%
  layout(yaxis=list(range=c(0,max_count_survival)))
her2_os_months<-plot_ly(survival_wide, x=~survival_wide$survival_group, y=~survival_wide$Her2, type="bar", name="HER2") %>%
  layout(yaxis=list(range=c(0,max_count_survival)))
lumA_os_months<-plot_ly(survival_wide, x=~survival_wide$survival_group, y=~survival_wide$LumA, type="bar", name="Luminal A") %>%
  layout(yaxis=list(range=c(0,max_count_survival)))
lumB_os_months<-plot_ly(survival_wide, x=~survival_wide$survival_group, y=~survival_wide$LumB, type="bar", name="Luminal B") %>%
  layout(yaxis=list(range=c(0,max_count_survival)))
normal_os_months<-plot_ly(survival_wide, x=~survival_wide$survival_group, y=~survival_wide$Normal, type="bar", name="Normal") %>%
  layout(yaxis=list(range=c(0,max_count_survival)))
fig_os_months<-subplot(basal_os_months, claudin_low_os_months, her2_os_months, lumA_os_months, lumB_os_months, normal_os_months, nrows=3) %>% 
  layout(title="Overall Survival (Months)")

fig_os_months

#orca(fig_os_months, "figures/large_set_overall_survival.pdf")

################## death from cancer ##################
deaths<-clinical_info %>% select("CLAUDIN_SUBTYPE", "VITAL_STATUS")
deaths_wide<-tabyl(deaths, VITAL_STATUS, CLAUDIN_SUBTYPE)
other_death<-which(deaths_wide$VITAL_STATUS=="Died of Other Causes")
deaths_wide<-deaths_wide[-other_death,]
deaths_wide<-deaths_wide[-1,]

max_count_death<-320

basal_death<-plot_ly(deaths_wide, x=~deaths_wide$VITAL_STATUS, y=~deaths_wide$Basal, type="bar", name="Basal") %>%
  layout(yaxis=list(range=c(0,max_count_death)))
claudin_low_death<-plot_ly(deaths_wide, x=~deaths_wide$VITAL_STATUS, y=~deaths_wide$`claudin-low`, type="bar", name="Claudin Low") %>%
  layout(yaxis=list(range=c(0,max_count_death)))
her2_death<-plot_ly(deaths_wide, x=~deaths_wide$VITAL_STATUS, y=~deaths_wide$Her2, type="bar", name="HER2") %>%
  layout(yaxis=list(range=c(0,max_count_death)))
lumA_death<-plot_ly(deaths_wide, x=~deaths_wide$VITAL_STATUS, y=~deaths_wide$LumA, type="bar", name="Luminal A") %>%
  layout(yaxis=list(range=c(0,max_count_death)))
lumb_death<-plot_ly(deaths_wide, x=~deaths_wide$VITAL_STATUS, y=~deaths_wide$LumB, type="bar", name="Luminal B") %>%
  layout(yaxis=list(range=c(0,max_count_death)))
normal_death<-plot_ly(deaths_wide, x=~deaths_wide$VITAL_STATUS, y=~deaths_wide$Normal, type="bar", name="Normal") %>%
  layout(yaxis=list(range=c(0,max_count_death)))
fig_death<-subplot(basal_death, claudin_low_death, her2_death, lumA_death, lumb_death, normal_death, nrows=3) %>% layout(title="Living status")

fig_death



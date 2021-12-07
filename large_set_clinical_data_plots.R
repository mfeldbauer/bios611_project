#Make a few plots showing clinical data for the large dataset

library(shiny)
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
expression_data<-read.csv("derived_data/highly_exp_and_var_genes_matrix_from_large_set.csv", header=T, sep=",", row.names=1)
clinical_info<-clinical_info[clinical_info$PATIENT_ID %in% colnames(expression_data),]

######################## ages #########################
ages<-clinical_info %>% select("CLAUDIN_SUBTYPE", "AGE_AT_DIAGNOSIS")
age_factor<-cut(clinical_info$AGE_AT_DIAGNOSIS, pretty(clinical_info$AGE_AT_DIAGNOSIS, 8))
labs<-levels(age_factor)

ages$age_group<-cut(clinical_info$AGE_AT_DIAGNOSIS, 
                    pretty(clinical_info$AGE_AT_DIAGNOSIS, 8), labels=labs)
ages_wide<-tabyl(ages, age_group, CLAUDIN_SUBTYPE)

################## survival in months #################
survival<-clinical_info %>% select("CLAUDIN_SUBTYPE", "OS_MONTHS", "VITAL_STATUS")
other_death_rows<-which(survival$VITAL_STATUS=="Died of Other Causes")
survival<-survival[-other_death_rows,] #exclude the ones who died of other causes
table(survival$VITAL_STATUS)

survival_factor<-cut(survival$OS_MONTHS, pretty(survival$OS_MONTHS, 8))
labs_survival<-levels(survival_factor)

survival$survival_group<-cut(survival$OS_MONTHS, pretty(survival$OS_MONTHS, 8), labels=labs_survival)
survival_wide<-tabyl(survival, survival_group, CLAUDIN_SUBTYPE)

################## death from cancer ##################
deaths<-clinical_info %>% select("CLAUDIN_SUBTYPE", "VITAL_STATUS")
deaths_wide<-tabyl(deaths, VITAL_STATUS, CLAUDIN_SUBTYPE)
other_death<-which(deaths_wide$VITAL_STATUS=="Died of Other Causes")
deaths_wide<-deaths_wide[-other_death,]
deaths_wide<-deaths_wide[-1,]

#################### relapse status ####################
relapse<-clinical_info %>% select("CLAUDIN_SUBTYPE", "RFS_STATUS")
table(relapse$RFS_STATUS)
relapse_wide<-tabyl(relapse, RFS_STATUS, CLAUDIN_SUBTYPE)
relapse_wide<-relapse_wide[-1,]

#################### relapse time ######################
relapse_time<-clinical_info %>% select("CLAUDIN_SUBTYPE", "RFS_MONTHS")
relapse_factor<-cut(relapse_time$RFS_MONTHS, pretty(relapse_time$RFS_MONTHS, 8))
labs_relapse<-levels(relapse_factor)

relapse_time$relapse_group<-cut(relapse_time$RFS_MONTHS, pretty(relapse_time$RFS_MONTHS, 8), labels=labs_relapse)
rfs_time_wide<-tabyl(relapse_time, relapse_group, CLAUDIN_SUBTYPE)

####################### plots ##########################
combined_data<-bind_rows(ages_wide, survival_wide, deaths_wide, relapse_wide, rfs_time_wide)
subtypes<-c("Basal"="Basal", "Claudin Low"="claudin-low", "Her2-enriched"="Her2", 
            "Luminal A"="LumA", "Luminal B"="LumB", "Normal"="Normal")
x_axis_options<-c("Age at Diagnosis" = "age_group", 
                  "Death Status" = "VITAL_STATUS",
                  "Survival (months)" = "survival_group",
                  "Time to recurrence (months)" = "relapse_group",
                  "Recurrence status" = "RFS_STATUS")

server<-function(input, output){
  output$plot<-renderPlotly({
    plt<-plot_ly(combined_data, x=~get(input$select_x), y=~get(input$select_y), 
                 type="bar") %>% layout(
                   xaxis=list(title=names(x_axis_options[which(x_axis_options==input$select_x)])),
                   yaxis=list(title='Number of Patients'),
                   title=names(subtypes[which(subtypes==input$select_y)])
                 )
  })
}

ui<-shinyUI(fluidPage(
  titlePanel("Explore Patient Data Based on Breast Cancer Subtype"),
  sidebarLayout(sidebarPanel(selectizeInput(inputId="select_x",
                                            label="Choose x-axis data",
                                            choices=x_axis_options),
                             selectizeInput(inputId="select_y",
                                            label="Choose subtype",
                                            choices=subtypes)),
                mainPanel(plotlyOutput("plot")))
))

shinyApp(ui, server,
         options=list(port=8080, host="0.0.0.0"))




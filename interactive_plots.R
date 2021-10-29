#interactive_plots.R
#Purpose: to make interactive plots with Shiny

library(shiny)
library(tidyverse)
library(plotly)
library(janitor)

patient_and_clinical_data<-read.csv("derived_data/patient_and_clinical_data.csv", header=TRUE,sep=",") %>%
  select(c("patient_id", "age_at_diagnosis",
           "cancer_type_detailed","pam50_._claudin.low_subtype",
           "er_status_measured_by_ihc","her2_status", "pr_status",
           "overall_survival_months", "overall_survival",
           "death_from_cancer"))

######################## ages #########################
ages<-patient_and_clinical_data %>% select("pam50_._claudin.low_subtype", "age_at_diagnosis")
age_factor<-cut(patient_and_clinical_data$age_at_diagnosis, 
                pretty(patient_and_clinical_data$age_at_diagnosis, 8))
labs<-levels(age_factor)

ages$age_group<-cut(patient_and_clinical_data$age_at_diagnosis, 
                        pretty(patient_and_clinical_data$age_at_diagnosis, 8), labels=labs)

ages_wide<-tabyl(ages, age_group, pam50_._claudin.low_subtype)

################## survival in months #################
survival<-patient_and_clinical_data %>% select("pam50_._claudin.low_subtype", "overall_survival_months")
survival_factor<-cut(patient_and_clinical_data$overall_survival_months,
                     pretty(patient_and_clinical_data$overall_survival_months, 8))
labs_survival<-levels(survival_factor)

survival$survival_group<-cut(patient_and_clinical_data$overall_survival_months,
                             pretty(patient_and_clinical_data$overall_survival_months, 8), labels=labs_survival)

survival_wide<-tabyl(survival, survival_group, pam50_._claudin.low_subtype)

################## death from cancer ##################
deaths<-patient_and_clinical_data %>% select("pam50_._claudin.low_subtype", "death_from_cancer")
deaths_wide<-tabyl(deaths, death_from_cancer, pam50_._claudin.low_subtype)


######################### plots #######################
combined_data<-bind_rows(ages_wide, survival_wide, deaths_wide)
subtypes<-c("Basal"="Basal", "Claudin Low"="claudin-low", "Her2-enriched"="Her2", 
            "Luminal A"="LumA", "Luminal B"="LumB", "Normal"="Normal")
x_axis_options<-c("Age at Diagnosis" = "age_group", 
                  "Death Status" = "death_from_cancer",
                  "Survival (months)" = "survival_group")

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


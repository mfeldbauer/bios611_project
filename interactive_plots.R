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

ages<-patient_and_clinical_data %>% select("pam50_._claudin.low_subtype", "age_at_diagnosis")
age_factor<-cut(patient_and_clinical_data$age_at_diagnosis, 
                pretty(patient_and_clinical_data$age_at_diagnosis, 8))
labs<-levels(age_factor)

ages$age_group<-cut(patient_and_clinical_data$age_at_diagnosis, 
                        pretty(patient_and_clinical_data$age_at_diagnosis, 8), labels=labs)

ages_wide<-tabyl(ages, age_group, pam50_._claudin.low_subtype)

plot_ly(ages_wide, x=~age_group, y=~Basal, type="bar")

server<-function(input, output){
  output$plot<-renderPlotly({
    plt<-plot_ly(ages_wide, x=~age_group, y=~get(input$select), 
                 type="bar", color=~age_group) %>% layout(
                   xaxis=list(title='Age at Diagnosis'),
                   yaxis=list(title='Number of Patients')
                 )
  })
}

ui<-shinyUI(fluidPage(
  titlePanel("Patient Ages based on Cancer Subtype"),
  plotlyOutput("plot"),
  selectInput("select", "Select", label=h3("Choose subtype"), 
              choices=c("Basal", "claudin-low", "Her2",
                           "LumA", "LumB", "Normal"))
))

shinyApp(ui, server,
         options=list(port=8080, host="0.0.0.0"))


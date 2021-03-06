# Databricks notebook source
# MAGIC %md
# MAGIC 
# MAGIC ## GLM model 

# COMMAND ----------

# MAGIC %md

# COMMAND ----------

# MAGIC %sh 
# MAGIC install.packages("lme4")

# COMMAND ----------

library(lme4)
library(tidyverse)
library(pscl)
library(parameters)
library(gt)
library(gsubfn)
library(proto)
library(sqldf)
library(RSQLite)

library(usethis)
library(devtools)
library(visdat)
library(skimr)
library(DataExplorer)

# COMMAND ----------

# MAGIC %sh ls /dbfs/FileStore/tables/

# COMMAND ----------

data<-read.csv("/dbfs/FileStore/tables/all_vars_for_zeroinf_analysis.csv")

# COMMAND ----------

head(data, 10)

# COMMAND ----------

dim(data)

# COMMAND ----------

glimpse(data)

# COMMAND ----------

summary(data)

# COMMAND ----------

str(data)

# COMMAND ----------

colnames(data)

# COMMAND ----------

colnames(data) <- c( "county", "confirmed_cases" , "confirmed_deaths" ,
 "state"  ,"length_of_lockdown" ,"cases" ,"deaths","POP_ESTIMATE_2018" , "total_state_pop",	'Active_Physicians_per_100000_Population_2018_AAMC',	'Total_Active_Patient_Care_Physicians_per_100000_Population_2018_AAMC',	'Active_Primary_Care_Physicians_per_100000_Population_2018_AAMC',	'Active_Patient_Care_Primary_Care_Physicians_per_100000_Population_2018_AAMC',	'Active_General_Surgeons_per_100000_Population_2018_AAMC',	'Active_Patient_Care_General_Surgeons_per_100000_Population_2018_AAMC',	'Percentage_of_Active_Physicians_Who_Are_Female_2018_AAMC',	'Percentage_of_Active_Physicians_Who_Are_Intertiol_Medical_Graduates_IMGs-2018_AAMC',	'Percentage_of_Active_Physicians_Who_Are_Age_60_or_Older_2018_AAMC',	'MD_and_DO_Student_Enrollment_per_100000_Population_AY_2018_2019_AAMC',	'Student_Enrollment_at_Public_MD_and_DO_Schools_per_100000_Population_AY_2018_2019_AAMC',	'Percentage_Change_in_Student_Enrollment_at_MD_and_DO_Schools_2008_2018_AAMC',	'Percentage_of_MD_Students_Matriculating_In_State_AY_2018_2019_AAMC',	'Total_Residents_Fellows_in_ACGME_Programs_per_100000_Population_as_of_December_31_2018_AAMC',	'Total_Residents_Fellows_in_Primary_Care_ACGME_Programs_per_100000_Population_as_of_Dec_31_2018_AAMC',	'Percentage_of_Residents_in_ACGME_Programs_Who_Are_IMGs_as_of_December_31_2018_AAMC',	'Ratio_of_Residents_and_Fellows_GME_to_Medical_Students_UME-AY_2017_2018_AAMC',	'Percent_Change_in_Residents_and_Fellows_in_ACGME_Accredited_Programs_2008_2018_AAMC',	'Percentage_of_Physicians_Retained_in_State_from_Undergraduate_Medical_Education_UME-2018_AAMC',	'All_Specialties_AAMC',	'State_Local_Government_hospital_beds_per_1000_people_2019',	'Non_profit_hospital_beds_per_1000_people_2019',	'For_profit_hospital_beds_per_1000_people_2019',	'Total_hospital_beds_per_1000_people_2019',	'Total_nurse_practitioners_2019',	'Total_physician_assistants_2019',	'Total_Hospitals_2019',	'Total_Primary_Care_Physicians_2019',	'Surgery_specialists_2019',	'Emergency_Medicine_specialists_2019',	'Total_Specialist_Physicians_2019',	'ICU_Beds',	'pop_fraction',	'Length_of_Life_rank',	'Quality_of_Life_rank',	'Health_Behaviors_rank',	'Clinical_Care_rank',	'Social-Economic_Factors_rank',	'Physical_Environment_rank',	'Adult_smoking_percentage',	'Adult_obesity_percentage',	'Excessive_drinking_percentage',	'Population_per_sq_mile',	'House_per_sq_mile',	'Share_of_Tests_with_Positive_COVID_19_Results', 'Number_of_Tests_with_Results_per_1000_Population'
)

# COMMAND ----------

view(data)

# COMMAND ----------

select(data, county, confirmed_cases)

# COMMAND ----------

data %>%
    group_by(county) %>%
    summarise(count = n())

# COMMAND ----------

vis_miss(data)
vis_dat(data)

# COMMAND ----------

skim(data)

# COMMAND ----------

#DataExplorer::create_report(data)

# COMMAND ----------

colnames(data)

# COMMAND ----------

data %>% 
select(county,length_of_lockdown, confirmed_cases,confirmed_deaths,POP_ESTIMATE_2018, POP_ESTIMATE_2018,ICU_Beds, Adult_obesity_percentage, Quality_of_Life_rank, Excessive_drinking_percentage, Population_per_sq_mile,
     Clinical_Care_rank, Adult_smoking_percentage,Total_Specialist_Physicians_2019,Physical_Environment_rank,  Number_of_Tests_with_Results_per_1000_Population) -> final_data

# COMMAND ----------

display(final_data)

# COMMAND ----------

results <-zeroinfl(confirmed_deaths ~ ICU_Beds + Adult_obesity_percentage + Quality_of_Life_rank + Excessive_drinking_percentage + Population_per_sq_mile + Clinical_Care_rank + Adult_smoking_percentage + Total_Specialist_Physicians_2019,Physical_Environment_rank + Number_of_Tests_with_Results_per_1000_Population, offset = log(POP_ESTIMATE_2018), data=final_data ,dist="negbin")
summary(results)

# COMMAND ----------

x <-model_parameters(results, exponentiate = TRUE)
x %>% 
  gt()

# COMMAND ----------

##Visualizing the deaths over ICU beds
final_data %>% 
  filter(confirmed_deaths > 20 & ICU_Beds <10) %>% 
  ggplot(aes(x = ICU_Beds, y = confirmed_deaths))+
  geom_point()+
  theme_classic()+
  ggtitle("Number of deaths in counties over ICU beds per 1000")+
  xlab("ICU beds per 1000")


# COMMAND ----------



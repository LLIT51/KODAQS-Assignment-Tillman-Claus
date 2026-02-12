######################################################
#01 Cleaning and creating the dataset




#Loading libraries
library(dplyr)
library(foreign)
library(tableone) 

##############
#Loading the waves

#loading files
wave6_dn <- read.dta("data/raw/sharew6_rel9-0-0_dn.dta")

wave6_ep <- read.dta("data/raw/sharew6_rel9-0-0_ep.dta")

wave6_ph <- read.dta("data/raw/sharew6_rel9-0-0_ph.dta")

wave7_dn <- read.dta("data/raw/sharew7_rel9-0-0_dn.dta")

wave7_ep <- read.dta("data/raw/sharew7_rel9-0-0_ep.dta")

wave7_ph <- read.dta("data/raw/sharew7_rel9-0-0_ph.dta")

wave8_dn <- read.dta("data/raw/sharew8_rel9-0-0_dn.dta")

wave8_ep <- read.dta("data/raw/sharew8_rel9-0-0_ep.dta")

wave8_ph <- read.dta("data/raw/sharew8_rel9-0-0_ph.dta")

wave9_dn <- read.dta("data/raw/sharew9_rel9-0-0_dn.dta")

wave9_ep <- read.dta("data/raw/sharew9_rel9-0-0_ep.dta")

wave9_ph <- read.dta("data/raw/sharew9_rel9-0-0_ph.dta")


# Merge the waves

wave6 <- wave6_dn %>%
  full_join(wave6_ep, by = "mergeid") %>%
  full_join(wave6_ph, by = "mergeid")

wave7 <- wave7_dn %>%
  full_join(wave7_ep, by = "mergeid") %>%
  full_join(wave7_ph, by = "mergeid")

wave8 <- wave8_dn %>%
  full_join(wave8_ep, by = "mergeid") %>%
  full_join(wave8_ph, by = "mergeid")

wave9 <- wave9_dn %>%
  full_join(wave9_ep, by = "mergeid") %>%
  full_join(wave9_ph, by = "mergeid")

# Adding trace variable

wave6 <- wave6 %>% mutate(wave = 6)
wave7 <- wave7 %>% mutate(wave = 7)
wave8 <- wave8 %>% mutate(wave = 8)
wave9 <- wave9 %>% mutate(wave = 9)

######################
# Create longitudinal dataset


# Reduce the waves

# Variables to keep:
#dn: mergeid, wave, country, dn003_ (year of birth), dn014_ (marital status), dn010_ (highest education), dn041_ (years of education), dn042_ (gender), 
#ep: mergeid, wave, ep005_ (employment), ep329_ (Retirement year), ep027_ (physical job demands), ep028_ (time pressure), ep029_ (little freedom), ep031_ (support), ep204_ (any earnings), ep205_ (employment earnings), ep078_ (average payment)
#ph: mergeid, wave, ph003_ (Self-rated health), ph004_ (Illness), ph005_ (Health limitations)

vars_keep <- c(
  "mergeid",
  "wave",
  "country",
  "dn003_",   # year of birth
  "dn010_",   # highest degree
  "dn014_",   # marital status
  "dn041_",   # years of education
  "dn042_",   # gender
  "ep005_",   # employment status
  "ep027_",   # physical job demands
  "ep028_",   # time pressure
  "ep029_",   # little freedom
  "ep031_",   # job support
  "ep078_",   # average payment
  "ep204_",   # any earning
  "ep205_",   # employment earnings
  "ph003_",   # self-rated health
  "ph004_",   # illness
  "ph005_"    # health limitation
)



reduce_wave <- function(df, vars) {
  present <- intersect(vars, names(df))
  df %>%
    select(all_of(present))
}

wave6_reduced <- wave6 %>% reduce_wave(vars_keep)
wave7_reduced <- wave7 %>% reduce_wave(vars_keep)
wave8_reduced <- wave8 %>% reduce_wave(vars_keep)
wave9_reduced <- wave9 %>% reduce_wave(vars_keep)


# connect the reduced waves to one panel dataset and save it

paneldata <- bind_rows(
  wave6_reduced,
  wave7_reduced,
  wave8_reduced,
  wave9_reduced
)

rm(list = setdiff(ls(), "paneldata"))

save(paneldata, file = "data/processed/paneldata.Rda")
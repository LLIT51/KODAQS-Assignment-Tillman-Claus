library(stargazer)
library(survival)

load("data/processed/paneldata.Rda")


##############
# Creating and inspecting sample


# Baseline Sample: People employed at baseline, at risk of retirement

baseline_ids <- paneldata %>%
  filter(wave == 6, work_status == "Employed or self-employed (including working for family business)") %>%
  pull(mergeid)

baseline_sample <- paneldata %>%
  filter(mergeid %in% baseline_ids)


# Inspecting missings

baseline_sample %>%
  summarise(across(
    c(y_birth,
      degree,
      married,
      y_educ,
      gender,
      work_status,
      phy_demands,
      t_pressure,
      no_freedom,
      support,
      m_earnings,
      employed,
      y_emp_earnings,
      srh,
      illness,
      limitations),
    ~ sum(is.na(.))
  ))


#######################
# Creating outcome variable "early retired" and sample of people at risk of early retirement


# Add interview year

baseline_sample <- baseline_sample %>%
  mutate(
    interview_year = case_when(
      wave == 6 ~ 2015,
      wave == 7 ~ 2017,
      wave == 8 ~ 2019,
      wave == 9 ~ 2021,
      TRUE ~ NA_real_
    )
  )

# create age variable

baseline_sample <- baseline_sample %>%
  mutate(
    age = interview_year - y_birth
  )

summary(baseline_sample$age)


# detect retirement event

baseline_sample <- baseline_sample %>%
  arrange(mergeid, wave) %>%
  group_by(mergeid) %>%
  mutate(
    retired_now = work_status == "Retired",
    first_retirement = retired_now & !lag(retired_now, default = FALSE)
  ) %>%
  ungroup()

baseline_sample %>%
  group_by(mergeid) %>%
  summarise(events = sum(first_retirement)) %>%
  table()


baseline_sample <- baseline_sample %>%
  mutate(
    early_retired = first_retirement
  )



# create dataset with right censoring at age 65

sample_early <- baseline_sample %>%
  filter(age <= 65)


# drop observations after first retirement event

cox_sample <- sample_early %>%
  arrange(mergeid, age) %>%
  group_by(mergeid) %>%
  mutate(
    event_age = ifelse(first_retirement, age, NA_real_),
    event_age = min(event_age, na.rm = TRUE)
  ) %>%
  filter(is.na(event_age) | age <= event_age) %>%
  ungroup()





#######################
# Analysis



#### Preparations
# change scales

likert_map <- c(
  "Strongly disagree" = 1,
  "Disagree"          = 2,
  "Agree"             = 3,
  "Strongly agree"    = 4
)

cox_sample <- cox_sample %>%
  mutate(
    phy_demands_num = recode(phy_demands, !!!likert_map),
    t_pressure_num  = recode(t_pressure,  !!!likert_map),
    no_freedom_num  = recode(no_freedom,  !!!likert_map),
    support_num     = recode(support,     !!!likert_map),
    poor_srh_num = recode(
      srh,
      "Excellent" = 1,
      "Very good" = 2,
      "Good"      = 3,
      "Fair"      = 4,
      "Poor"      = 5
    )
  )

# change dont knows to na

vars <- c("phy_demands", "t_pressure", "no_freedom", "support", "srh")

cox_sample <- cox_sample %>%
  mutate(across(all_of(vars), ~ na_if(., "Don't know")))

cox_sample <- cox_sample %>%
  mutate(gender = na_if(gender, "Don't know")) %>%
  filter(!is.na(gender))
cox_sample <- cox_sample %>%
  mutate(gender = droplevels(gender))



# create lagged variables for working conditions and monthly earnings, NA otherwise

cox_sample <- cox_sample %>%
  arrange(mergeid, wave) %>%
  group_by(mergeid) %>%
  mutate(
    phy_demands_lag = lag(phy_demands_num),
    t_pressure_lag = lag(t_pressure_num),
    no_freedom_lag = lag(no_freedom_num),
    support_lag = lag(support_num),
    y_emp_earnings_lag = lag(y_emp_earnings),
    poor_srh_lag = lag(poor_srh_num),
    age_start = lag(age),
    age_end = age
  ) %>%
  ungroup()

cox_sample_clean <- cox_sample %>%
  filter(!is.na(age_start)) %>%
  filter(age_start < 65) %>%


save(cox_sample_clean, file = "data/processed/cox_data.Rda")


##### Model calculation

# Baseline model
baseline_model <- coxph(
  Surv(age_start, age_end, early_retired) ~
    phy_demands_lag +
    t_pressure_lag +
    no_freedom_lag +
    support_lag +
    poor_srh_lag +
    y_emp_earnings_lag +
    gender +
    cluster(mergeid),
  data = cox_sample_clean
)


# Export as HTML or text table

dir.create("output", showWarnings = FALSE)

stargazer(baseline_model,
          type = "html",
          out = "output/cox_models_table.html",
          ci = TRUE,
          single.row = TRUE)

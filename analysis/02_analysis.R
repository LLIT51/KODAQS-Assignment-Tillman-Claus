

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
    early_retired = ifelse(first_retirement & age < 65, 1, 0),
    at_risk = age < 65
  )


# create dataset with right censoring at age 65

sample_early <- baseline_sample %>%
  filter(age <= 65)


# drop observations after first retirement event

cox_sample <- sample_early %>%
  arrange(mergeid, age) %>%
  group_by(mergeid) %>%
  filter(age <= age[which(early_retired == 1)[1]] | all(early_retired == 0)) %>%
  ungroup()




######################
# Descriptives


sample_early %>%
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
# Analysis

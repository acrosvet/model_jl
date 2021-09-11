
source("./r_scripts/libraries.r")
library(lubridate)
# Import the model run from the animalModel
run <- read_csv("/home/alex/Documents/julia_abm/model_jl/export/split_model_run.csv")



tmp = run %>% filter(DIM == 280)

run %>%
  select(ModelStep, Day, CurrentLac)

  max(run$CurrentLac)

# Generate a ploot of population dynamics over time
run %>%  
  mutate(Day = lubridate::ymd(Day)) %>%
  group_by(Day, AnimalStage) %>% 
  summarise(count = n()) %>% 
  pivot_wider(names_from = AnimalStage, values_from = count) %>% 
  plot_ly() %>% 
  add_trace(x = ~Day, y = ~L, type = 'bar', name = 'L') %>% 
  add_trace(x = ~Day, y = ~D, type = 'bar', name = 'D') %>% 
  add_trace(x = ~Day, y = ~C, type = 'bar', name = 'C') %>%
  add_trace(x = ~Day, y = ~H, type = 'bar', name = 'H') %>%
  add_trace(x = ~Day, y = ~DH, type = 'bar', name = 'DH') %>%
  add_trace(x = ~Day, y = ~W, type = 'bar', name = 'W') %>%
  layout(barmode = 'stack')

# Not in calf rate --------------------------

run %>%
  filter(Day != 0) %>%
  filter(AnimalStage == "L") %>%
  mutate(Day = lubridate::ymd(Day)) %>%
  mutate(msd = lubridate::ymd(msd)) %>%
  filter(Day == (msd %m+% weeks(13))) %>%
  group_by(Day, PregStat) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = PregStat, values_from = count) %>%
  mutate(empty_rate = 100*(E/(E+P))) %>%
  plot_ly() %>%
  add_trace(x = ~Day, y = ~empty_rate)


# Calving pattern ------------------------------

calved_psc <- run %>%
  filter(Day != 0) %>%
  filter(AnimalStage == "L" | AnimalStage == "D" | AnimalStage == "DH") %>%
  mutate(Day = lubridate::ymd(Day)) %>%
  mutate(msd = lubridate::ymd(msd)) %>%
  mutate(psc = lubridate::ymd(psc)) %>%
  mutate("psc_3" = psc %m+% weeks(3)) %>%
  mutate("psc_6" = psc %m+% weeks(6)) %>%
  mutate("psc_9" = psc %m+% weeks(9)) %>%
  mutate("psc_12" = psc %m+% weeks(12)) %>%
  filter(Day == psc ) %>%
  group_by(AnimalStage, psc) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = AnimalStage, values_from = count) %>%
  mutate(across(where(is.numeric), ~replace_na(.x, 0))) %>%
  mutate(calved = 100*(L / (L + D + DH)))

calved_psc_3 <- run %>%
  filter(Day != 0) %>%
  filter(AnimalStage == "L" | AnimalStage == "D" | AnimalStage == "DH") %>%
  mutate(Day = lubridate::ymd(Day)) %>%
  mutate(msd = lubridate::ymd(msd)) %>%
  mutate(psc = lubridate::ymd(psc)) %>%
  mutate("psc_3" = psc %m+% weeks(3)) %>%
  mutate("psc_6" = psc %m+% weeks(6)) %>%
  mutate("psc_9" = psc %m+% weeks(9)) %>%
  mutate("psc_12" = psc %m+% weeks(12)) %>%
  filter(Day == psc_3 ) %>%
  group_by(AnimalStage, psc_3) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = AnimalStage, values_from = count) %>%
  replace(is.na(.), 0) %>%
  mutate(calved = 100*(L / (L + D + DH)))


calved_psc_6 <- run %>%
  filter(Day != 0) %>%
  filter(AnimalStage == "L" | AnimalStage == "D" | AnimalStage == "DH") %>%
  mutate(Day = lubridate::ymd(Day)) %>%
  mutate(msd = lubridate::ymd(msd)) %>%
  mutate(psc = lubridate::ymd(psc)) %>%
  mutate("psc_3" = psc %m+% weeks(3)) %>%
  mutate("psc_6" = psc %m+% weeks(6)) %>%
  mutate("psc_9" = psc %m+% weeks(9)) %>%
  mutate("psc_12" = psc %m+% weeks(12)) %>%
  filter(Day == psc_6 ) %>%
  group_by(AnimalStage, psc_6) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = AnimalStage, values_from = count) %>%
  mutate(across(where(is.numeric), ~replace_na(.x, 0))) %>%
  mutate(calved = 100*(L / (L + D + DH))) %>%
  plot_ly() %>%
  add_trace(x = ~psc_6, y = ~calved)


calved_psc_9 <- run %>%
  filter(Day != 0) %>%
  filter(AnimalStage == "L" | AnimalStage == "D" | AnimalStage == "DH") %>%
  mutate(Day = lubridate::ymd(Day)) %>%
  mutate(msd = lubridate::ymd(msd)) %>%
  mutate(psc = lubridate::ymd(psc)) %>%
  mutate("psc_3" = psc %m+% weeks(3)) %>%
  mutate("psc_6" = psc %m+% weeks(6)) %>%
  mutate("psc_9" = psc %m+% weeks(9)) %>%
  mutate("psc_12" = psc %m+% weeks(12)) %>%
  filter(Day == psc_9 ) %>%
  group_by(AnimalStage, psc_9) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = AnimalStage, values_from = count) %>%
  mutate(across(where(is.numeric), ~replace_na(.x, 0))) %>%
  mutate(calved = 100*(L / (L + D )))


calved_psc_12 <- run %>%
  filter(Day != 0) %>%
  filter(AnimalStage == "L" | AnimalStage == "D" | AnimalStage == "DH") %>%
  mutate(Day = lubridate::ymd(Day)) %>%
  mutate(msd = lubridate::ymd(msd)) %>%
  mutate(psc = lubridate::ymd(psc)) %>%
  mutate("psc_3" = psc %m+% weeks(3)) %>%
  mutate("psc_6" = psc %m+% weeks(6)) %>%
  mutate("psc_9" = psc %m+% weeks(9)) %>%
  mutate("psc_12" = psc %m+% weeks(12)) %>%
  filter(Day == psc_12 ) %>%
  group_by(AnimalStage, psc_12) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = AnimalStage, values_from = count) %>%
  mutate(across(where(is.numeric), ~replace_na(.x, 0))) %>%
  mutate(calved = 100*(L / (L + D + DH)))


# Inspect in calf rates  -------------------------
six_icr = run %>% 
  filter(AnimalStage != 0) %>% 
  mutate(Day = lubridate::ymd(Day)) %>%
  mutate(eom = lubridate::ymd(msd) %m+% weeks(13)) %>%
  filter(Day == eom) %>%
  filter(AnimalStage == "L") %>%
  mutate(dic = dic - 47) %>%
  mutate(PregStat = ifelse(dic > 0, "P", "E")) %>%
  group_by(Day, PregStat) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = PregStat, values_from = count) %>%
  mutate(icr = 100*(P/(E+P)))

# Calving by msd

run %>%
  filter()

# Inspect the ages of heifers

heifers <- run %>%
            #filter(AnimalStage == "H") %>%
            mutate(Day = lubridate::ymd(Day)) %>%
            mutate(msd = lubridate::ymd(msd)) %>%
            filter(Day == msd) %>%
            filter(AnimalStage == "DH")

write_csv(heifers, "./export/heifers.csv")

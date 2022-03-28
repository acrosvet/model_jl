#Undertake survival analysis 

# Determine the time taken for infection to die out

library(tidyverse)
library(ggfortify)
library(survival)

all_incidence <- read_csv("./export/all_incidence.csv")

all_incidence$seq = as.factor(all_incidence$seq)
all_incidence$day = all_incidence$timestep - min(all_incidence$timestep)
all_incidence$day = as.numeric(all_incidence$day)
all_incidence$calving_system = as.factor(all_incidence$calving_system)
all_incidence$id = as.factor(all_incidence$seq)

#Determine the survival times until no carriers are left in a herd

st_nc <- all_incidence %>% 
  group_by(id) %>% 
  mutate(no_carriers = ifelse(inc_car == 0, 1, 0)) %>% 
  mutate(event_date = ifelse(no_carriers == TRUE, day, 3650)) %>% 
  mutate(start = min(day), stop = min(na.omit(event_date))) %>% 
  filter(day == event_date) %>% 
  select(id, start, stop, status = no_carriers, calving_system) %>% 
 
  distinct(id, .keep_all = TRUE)
  
  
carrier.km <- survfit(Surv(stop, status) ~ 1, conf.type = "none", type =
                       "kaplan-meier", data = st_nc)
plot(carrier.km, xlab = "Model day", ylab = "S(t)", main = "Days to no carriers (n = 1500 farms)")

survfit(Surv(stop, status) ~ 1, data = st_nc)

# Differential survival times 

carrier.km <- survfit(Surv(stop, status) ~ calving_system, conf.type = "none", type =
                        "kaplan-meier", data = st_nc)
plot(carrier.km, xlab = "Model day", ylab = "S(t)",  lty = c("solid", "dashed", "dotted"), main = "Days to no carriers (n = 1500 farms)")
legend(750, .9, c("Spring", "Split", "Batch"),lty = 1:3)

survdiff(Surv(stop, status) ~ calving_system, data = st_nc)

# Days until no resistance 

st_nr <- all_incidence %>% 
  group_by(id) %>% 
  mutate(no_carriers = ifelse(inc_car_r == 0, 1, 0)) %>% 
  mutate(event_date = ifelse(no_carriers == TRUE, day, 3650)) %>% 
  mutate(start = min(day), stop = min(na.omit(event_date))) %>% 
  filter(day == event_date) %>% 
  select(id, start, stop, status = no_carriers, calving_system) %>% 
  
  distinct(id, .keep_all = TRUE)


carrier_r.km <- survfit(Surv(stop, status) ~ 1, conf.type = "none", type =
                        "kaplan-meier", data = st_nr)
plot(carrier_r.km, xlab = "Model day", ylab = "S(t)", main = "Days to no resistant carriers (n = 1500 farms)")

survfit(Surv(stop, status) ~ 1, data = st_nr)

# Differential survival times 

carrier_r.km <- survfit(Surv(stop, status) ~ calving_system, conf.type = "plain", type =
                        "kaplan-meier", data = st_nr)
plot(carrier_r.km, xlab = "Model day", ylab = "S(t)",  lty = c("solid", "dashed", "dotted"), main = "Days to no carriers (n = 1500 farms)")
legend(750, .9, c("Spring", "Split", "Batch"),lty = 1:3)

survdiff(Surv(stop, status) ~ calving_system, data = st_nc)

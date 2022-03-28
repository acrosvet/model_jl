library(lhs)
library(tidyverse)
library(truncnorm)


runs = 500

## Specify the initial parameters
parameter_values <- list(
  #"optimal_stock" = list(min = 80, max = 1500, random_function = "qunif"),
  "treatment_prob" = list(min = 0, max = 1.0, random_function = "qunif"),
  "density_calves" = list(min = 3, max = 5, random_function = "qunif"),
  "vacc_rate" = list(min = 0, max = 1.0, random_function = "qunif"),
  "fpt_rate" = list(min = 0, max = 1.0, random_function = "qunif"),
  "vacc_efficacy" = list(min = 0, max = 0.5, random_function = "qunif")
)

sample_count <- runs

parameter_names <- names(parameter_values)

lhs_design <- randomLHS(sample_count, length(parameter_values))

lhs_design <- lapply(seq(1,length(parameter_values)), function(i) {
  match.fun(parameter_values[[i]]$random_function)(lhs_design[,i], parameter_values[[i]]$min, parameter_values[[i]]$max)
})

names(lhs_design) <- parameter_names

lhs_design



lhs_design$density_calves = round(lhs_design$density_calves)
lhs_design$optimal_stock = round(rtruncnorm(runs, a = 80, b = 1500, mean = 273, sd = 500))
lhs_design$pen_decon = replicate(runs, ifelse(runif(1) < 0.5, TRUE, FALSE))
lhs_design$status = replicate(runs, ifelse(runif(1)<0.05, 2, 1))
lhs_design$calving_system = 2


sensitivity_args <- as_tibble(lhs_design) %>% 
mutate(run = row_number()) %>% 
mutate(id = row_number()) %>%
mutate(prev_r = ifelse(status == 2, 0.01, 0.00),
       prev_p = ifelse(status == 1, 0.02, 0.01),
       prev_cr = ifelse(status == 2, 0.05, 0.00),
       prev_cp = ifelse(status == 1, 0.10, 0.05),
       density_dry = 250,
       density_lactating = 50,
       vacc_efficacy = 0.1
        ) %>% 
mutate(seq = row_number())

write_csv(sensitivity_args, "./sensitivity_split.csv")

read_csv("./sensitivity_spring.csv")

trans = read_csv("./export/transmissions.csv")

trans = trans %>%
  filter(step != 0) %>%
  group_by(step, type) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = type, values_from = count) %>%
  mutate(across(where(is.numeric), ~replace_na(., 0)))

library(plotly)

trans %>%
  plot_ly() %>%
  add_trace(x = ~step, y = ~aa, type = 'bar', name = 'animal') %>%
  add_trace(x = ~step, y = ~cc, type = 'bar', name = 'calf feeding') %>%
  add_trace(x = ~step, y = ~mm, type = 'bar', name = 'milking') %>%
  add_trace(x = ~step, y = ~ee, type = 'bar', name = 'environmental')%>%
  layout(barmode = 'stack')  

read_csv("./sensitivity_spring.csv") %>% mutate(seq = row_number()) %>% write_csv(., "./sensitivity_spring.csv")

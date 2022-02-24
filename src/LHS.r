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
lhs_design$calving_system = replicate(runs,
      case_when(
        runif(1) < 0.05 ~ 3,
        runif(1) < 0.3 ~ 1,
        runif(1) > 0.35 ~ 2
      )
      )
lhs_design$calving_system = replace_na(lhs_design$calving_system, 2)

sensitivity_args <- as_tibble(lhs_design) %>% mutate(run = row_number()) %>% mutate(id = row_number())

write_csv(sensitivity_args, "./sensitivity_spring.csv")

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

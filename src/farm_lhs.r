
library(lhs)
library(tidyverse)
library(truncnorm)

for(i in 1:1000){
runs = 250

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
lhs_design$density_lactating = 50
lhs_design$density_dry = 250
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

for(j in 1:length(lhs_design$optimal_stock)){
    lhs_design$prev_r[j] = ifelse(lhs_design$status[j] == 1, 0, 0.01)
    lhs_design$prev_p[j] = ifelse(lhs_design$status[j] == 1, 0.02, 0.01)
    lhs_design$prev_cp[j] = ifelse(lhs_design$status[j] == 1, 0.1, 0.05)
    lhs_design$prev_cr[j] = ifelse(lhs_design$status[j] == 2, 0.05, 0)
}

sensitivity_args <- as_tibble(lhs_design) %>% mutate(farm = row_number()) %>% mutate(run = !!i)

write_csv(sensitivity_args, paste0("./sense/sensitivity_args_",i,".csv"))

}
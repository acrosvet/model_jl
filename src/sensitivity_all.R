#R script to interpret model outputs 
options(bitmapType='cairo')
library(tidyverse)
library(data.table)
library(plotly)

epi.prcc <- function (dat, sided.test = 2, conf.level = 0.95) 
{
  N <- dim(dat)[1]
  K <- dim(dat)[2] - 1
  if (K > N) 
    stop("Error: the number of replications of the model must be greater than the number of model parameters")
  mu <- (1 + N)/2
  for (i in 1:(K + 1)) {
    dat[, i] <- rank(dat[, i])
  }
  C <- matrix(rep(0, times = (K + 1)^2), nrow = (K + 1))
  for (i in 1:(K + 1)) {
    for (j in 1:(K + 1)) {
      r.it <- dat[, i]
      r.jt <- dat[, j]
      r.js <- r.jt
      c.ij <- sum((r.it - mu) * (r.jt - mu))/sqrt(sum((r.it - 
                                                         mu)^2) * sum((r.js - mu)^2))
      C[i, j] <- c.ij
    }
  }
  if (is.na(C[K + 1, K + 1])) {
    gamma.iy <- rep(0, times = K)
    t.iy <- gamma.iy * sqrt((N - 2)/(1 - gamma.iy^2))
    p <- rep(1, times = K)
    df <- rep((N - 2), times = K)
    N. <- 1 - ((1 - conf.level)/2)
    t <- qt(p = N., df = df)
    se.t <- gamma.iy/t.iy
    gamma.low <- gamma.iy - (t * se.t)
    gamma.upp <- gamma.iy + (t * se.t)
    rval <- data.frame(est = gamma.iy, lower = gamma.low, 
                       upper = gamma.upp, test.statistic = t.iy, df = df, 
                       p.value = p)
    return(rval)
  }
  else {
    B <- solve(C)
    gamma.iy <- c()
    for (i in 1:K) {
      num <- -B[i, (K + 1)]
      den <- sqrt(B[i, i] * B[(K + 1), (K + 1)])
      gamma.iy <- c(gamma.iy, num/den)
    }
    t.iy <- gamma.iy * sqrt((N - 2)/(1 - gamma.iy^2))
    df <- rep((N - 2), times = K)
    if (sided.test == 2) {
      p <- 2 * pt(abs(t.iy), df = N - 2, lower.tail = FALSE)
    }
    if (sided.test == 1) {
      p <- pt(abs(t.iy), df = N - 2, lower.tail = FALSE)
    }
    N. <- 1 - ((1 - conf.level)/2)
    t <- qt(p = N., df = df)
    se.t <- gamma.iy/t.iy
    gamma.low <- gamma.iy - (t * se.t)
    gamma.upp <- gamma.iy + (t * se.t)
    rval <- data.frame(est = gamma.iy, lower = gamma.low, 
                       upper = gamma.upp, test.statistic = t.iy, df = df, 
                       p.value = p)
    return(rval)
  }
}

# Sensitivity analysis for split models ---------------------------------------
#List the output files
split_files <- list.files(
  "./export/sensitivity/split",
  full.names = TRUE
) %>% sort()

#Create a file import function
split_import <- function(file){
  fread(file) %>%
    mutate(seq = file) %>%
    mutate(seq = str_remove_all(seq, "./export/sensitivity/split/split_sense" )) %>%
    mutate(seq = str_remove_all(seq, ".csv"))
}

#Define the first file and bring in the rest
split_results <- split_import(split_files[1])
for(i in 2:length(split_files)){
  split_results =  bind_rows(split_import(split_files[i]), split_results)
}

split_results <- split_results %>% mutate(seq = paste0("split",seq))

#Determine daily incidence 

split_incidence <- split_results %>%
  group_by(seq, timestep) %>% 
  mutate(total_stock = num_calves + num_heifers + num_dh + num_lactating + num_dry) %>% 
  summarise(
    inc_inf = (pop_p + pop_r)/total_stock,
    inc_r = pop_r/total_stock,
    inc_p = pop_p/total_stock,
    inc_car = (pop_car_r + pop_car_p)/total_stock,
    inc_car_r = pop_car_r/total_stock,
    inc_car_p = pop_car_p/total_stock,
    inc_rec = (pop_rec_r + pop_rec_p)/total_stock,
    inc_sus = pop_s/total_stock
  )  %>% 
  filter(timestep != "0-01-01")  %>% 
  mutate(seq = str_squish(seq)) %>% 
  mutate(calving_system = 2)

# Spring
# Sensitivity analysis for spring models ---------------------------------------
#List the output files
spring_files <- list.files(
  "./export/sensitivity/spring",
  full.names = TRUE
) %>% sort()

#Create a file import function
spring_import <- function(file){
  fread(file) %>%
    mutate(seq = file) %>%
    mutate(seq = str_remove_all(seq, "./export/sensitivity/spring/spr_sense" )) %>%
    mutate(seq = str_remove_all(seq, ".csv"))
}

#Define the first file and bring in the rest
spring_results <- spring_import(spring_files[1])
for(i in 2:length(spring_files)){
  spring_results =  bind_rows(spring_import(spring_files[i]), spring_results)
}
spring_results <- spring_results %>% mutate(seq = paste0("spring",seq))
#Determine daily incidence 

spring_incidence <- spring_results %>%
  group_by(seq, timestep) %>% 
  mutate(total_stock = num_calves + num_heifers + num_dh + num_lactating + num_dry) %>% 
  summarise(
    inc_inf = (pop_p + pop_r)/total_stock,
    inc_r = pop_r/total_stock,
    inc_p = pop_p/total_stock,
    inc_car = (pop_car_r + pop_car_p)/total_stock,
    inc_car_r = pop_car_r/total_stock,
    inc_car_p = pop_car_p/total_stock,
    inc_rec = (pop_rec_r + pop_rec_p)/total_stock,
    inc_sus = pop_s/total_stock
  )  %>% 
  filter(timestep != "0-01-01")  %>% 
  mutate(seq = str_squish(seq)) %>% 
  mutate(calving_system = 1)

# Sensitivity analysis for batch models ---------------------------------------
#List the output files
batch_files <- list.files(
  "./export/sensitivity/batch",
  full.names = TRUE
) %>% sort()

#Create a file import function
batch_import <- function(file){
  fread(file) %>%
    mutate(seq = file) %>%
    mutate(seq = str_remove_all(seq, "./export/sensitivity/batch/batch_sense" )) %>%
    mutate(seq = str_remove_all(seq, ".csv"))
}

#Define the first file and bring in the rest
batch_results <- batch_import(batch_files[1])
for(i in 2:length(batch_files)){
  batch_results =  bind_rows(batch_import(batch_files[i]), batch_results)
}

batch_results <- batch_results %>% mutate(seq = paste0("batch",seq))

#Determine daily incidence 

batch_incidence <- batch_results %>%
  group_by(seq, timestep) %>% 
  mutate(total_stock = num_calves + num_heifers + num_dh + num_lactating + num_dry) %>% 
  summarise(
    inc_inf = (pop_p + pop_r)/total_stock,
    inc_r = pop_r/total_stock,
    inc_p = pop_p/total_stock,
    inc_car = (pop_car_r + pop_car_p)/total_stock,
    inc_car_r = pop_car_r/total_stock,
    inc_car_p = pop_car_p/total_stock,
    inc_rec = (pop_rec_r + pop_rec_p)/total_stock,
    inc_sus = pop_s/total_stock
  )  %>% 
  filter(timestep != "0-01-01")  %>% 
  mutate(seq = str_squish(seq)) %>%
  mutate(calving_system = 3)

all_incidence <- bind_rows(spring_incidence, split_incidence, batch_incidence)


batch_parms <- read_csv("./sensitivity_batch.csv") %>% mutate(seq = paste("batch", as.character(seq)))

spring_parms <- read_csv("./sensitivity_spring.csv") %>% mutate(seq = paste("spring", as.character(seq)))


split_parms <- read_csv("./sensitivity_split.csv") %>% mutate(seq = paste("split", as.character(seq)))

# All PRCC

outputs <- list(c("inc_inf", "inc_r", "inc_p", "inc_car", "inc_car_r", "inc_car_p", "inc_rec", "inc_sus"))


prcc_plots <- function(type){
  
  spring <- all_incidence %>% filter(calving_system == "1") 
  spring <- left_join(spring, spring_parms, by = c("seq" = "seq"))
  
  split <- all_incidence %>% filter(calving_system == "2") 
  split <- left_join(split, split_parms, by = c("seq" = "seq"))
  
  batch <- all_incidence %>% filter(calving_system == "3") 
  batch  <- left_join(batch, batch_parms, by = c("seq" = "seq"))
  
  all_incidence <- bind_rows(spring, split, batch)  %>%  rename(calving_system = calving_system.x) %>% select(-calving_system.y)
  
  all_parametrised <- all_incidence %>% select(seq, timestep, !!type, treatment_prob, density_calves, vacc_rate, fpt_rate, optimal_stock, pen_decon, calving_system)
  
  
  #all_parametrised <- left_join(all_res, all_parms, by = c("seq" = "seq"))
  
  
  
  prcc_frame <- all_parametrised  %>% 
    ungroup() %>% 
    select(
      treatment_prob,
      density_calves,
      vacc_rate,
      fpt_rate,
      optimal_stock,
      pen_decon,
      calving_system,
      !!type
    ) %>% 
    as.data.frame()
  
  frame_names <- prcc_frame[1:7]
  frame_names <- names(frame_names)
  
  prcc_eval <- epi.prcc(prcc_frame, conf.level = 0.95) 
  prcc_eval <- prcc_eval  %>% mutate(variable = frame_names)
  
  prcc_eval
  
  
  plot_prcc <- 
    prcc_eval %>%
    ggplot(aes(y =fct_rev(as.factor(variable)), x = est)) +
    geom_point() +
    geom_errorbar(aes(xmin = lower, xmax = upper)) + 
    theme_bw() +
    labs(
      title = paste0("PRCC (1000 all simulations), daily % ", {{type}})) +
    xlab("PRCC (95% CI)") +
    ylab("Variable") +
    geom_vline(xintercept = 0, color = 'red')
  
  
  
  ggsave(paste0("./export/plots/all", type, "_prcc",".bmp"), plot = plot_prcc)
}

pmap(outputs, prcc_plots)

# Side by side plots

prcc_sbs <- function(type){
  
  spring <- all_incidence %>% filter(calving_system == "1") 
  spring <- left_join(spring, spring_parms, by = c("seq" = "seq"))
  
  split <- all_incidence %>% filter(calving_system == "2") 
  split <- left_join(split, split_parms, by = c("seq" = "seq"))
  
  batch <- all_incidence %>% filter(calving_system == "3") 
  batch  <- left_join(batch, batch_parms, by = c("seq" = "seq"))
  
  all_incidence <- bind_rows(spring, split, batch)  %>%  rename(calving_system = calving_system.x) %>% select(-calving_system.y)
  
  all_parametrised <- all_incidence %>% select(seq, timestep, !!type, treatment_prob, density_calves, vacc_rate, fpt_rate, optimal_stock, pen_decon, calving_system)
  
  
  #all_parametrised <- left_join(all_res, all_parms, by = c("seq" = "seq"))
  
  
  
  prcc_frame <- all_parametrised  %>% 
    ungroup() %>% 
    select(
      treatment_prob,
      density_calves,
      vacc_rate,
      fpt_rate,
      optimal_stock,
      pen_decon,
      calving_system,
      !!type
    ) %>% 
    as.data.frame()
  
  frame_names <- prcc_frame[1:7]
  frame_names <- names(frame_names)
  
  prcc_eval <- epi.prcc(prcc_frame, conf.level = 0.95) 
  prcc_eval <- prcc_eval  %>% mutate(variable = frame_names)
  
  prcc_eval <- prcc_eval %>% mutate(var = !!type)
  
 return(prcc_eval)
}

all_frame <- pmap_dfr(outputs, prcc_sbs)

gen_type_plots <- function(variable){
plot_prcc <- 
  all_frame %>%
  filter(variable == !!variable) %>% 
  ggplot(aes(y =fct_rev(as.factor(var)), x = est)) +
  geom_point() +
  geom_errorbar(aes(xmin = lower, xmax = upper)) + 
  theme_bw() +
  labs(
    title = paste0("PRCC (1000 all simulations), daily % ", {{variable}})) +
  xlab("PRCC (95% CI)") +
  ylab("Variable") +
  geom_vline(xintercept = 0, color = 'red')

ggsave(paste0("./export/plots/all", variable, "_prcc",".bmp"), plot = plot_prcc)
}

variables <- list(unique(all_frame$variable))

pmap(variables, gen_type_plots)

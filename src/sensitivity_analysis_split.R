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
  mutate(seq = str_squish(seq))

# Visualise the data, generating plots for all variables of interest
#Define a function for generating multiple plots
incidence_plots <- function(type){
  
  p = ggplot(data = split_incidence, aes(x = timestep, y = !!sym(type)), color = seq) +       
    geom_line(size = 0.05, alpha = 0.5) +
    geom_smooth(se = TRUE) +
    ggtitle(paste0("split model (500 runs) ", {{type}}))
  
  ggsave(paste0("./export/plots/", "split_inc_",type,".bmp"), plot = p)
  
}

outputs <- list(c("inc_inf", "inc_r", "inc_p", "inc_car", "inc_car_r", "inc_car_p", "inc_rec", "inc_sus"))

pmap(outputs, incidence_plots)



#Determine PRCCs ------------------------------------------------------------------------------------------
#Import the parameters for each run

split_parms <- read_csv("./sensitivity_split.csv") %>% mutate(seq = as.character(seq))

#Summarise parameters

#Bind the parameters to the results



prcc_plots <- function(type){
  
  split_res <- split_incidence %>% select(seq, timestep, !!type)
  
  split_parametrised <- left_join(split_res, split_parms, by = c("seq" = "seq"))
  
  prcc_frame <- split_parametrised  %>% 
    ungroup() %>% 
    select(
      treatment_prob,
      density_calves,
      vacc_rate,
      fpt_rate,
      optimal_stock,
      pen_decon,
      !!type
    ) %>% 
    as.data.frame()
  
  frame_names <- prcc_frame[1:6]
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
      title = paste0("PRCC (1000 split simulations), daily % ", {{type}})) +
    xlab("PRCC (95% CI)") +
    ylab("Variable") +
    geom_vline(xintercept = 0, color = 'red')
  
  
  ggsave(paste0("./export/plots/split", type, "_prcc",".bmp"), plot = plot_prcc)
}

pmap(outputs, prcc_plots)
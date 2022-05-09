#Bring in the spring example data
library(tidyverse)
library(plotly)
library(ggpubr)
library(kableExtra)

# Spring herds --------------------------------------------------

spring_example <- read_csv("./export/spring_example.csv") %>% 
  filter(timestep != "0-01-01") %>% 
  mutate(step = row_number()) %>% 
  filter(step > 365*2) %>% 
  mutate(season = "Spring")

split_example <- read_csv("./export/split_example.csv") %>% 
  filter(timestep != "0-01-01") %>% 
  mutate(step = row_number()) %>% 
  filter(step > 365*2) %>% 
  mutate(season = "Split")
# Create a plot of population dynamics

batch_example <- read_csv("./export/batch_example.csv") %>% 
  filter(timestep != "0-01-01") %>% 
  mutate(step = row_number()) %>% 
  filter(step > 365*2) %>% 
  mutate(season = "Batch")

examples <- reduce(list(spring_example, split_example, batch_example), dplyr::bind_rows)

calves = examples %>% 
  ggplot(aes(x = step, y = num_calves, linetype = season)) +
  geom_line() +
  ylim(0,600) + 
  theme_minimal() + ylab("") + 
  xlab("") + 
  ggtitle("Calves") +
  theme(plot.title = element_text(size=22)) +
  labs(color="Calving system")



weaned = examples %>% 
  ggplot(aes(x = step, y = num_weaned, linetype = season)) +
  geom_line() +
  ylim(0,600) + 
  theme_minimal() + ylab("") + 
  xlab("") + 
  ggtitle("Weaned")+
  theme(plot.title = element_text(size=22)) +
  labs(color="Calving system")
  

heifers = examples %>% 
  ggplot(aes(x = step, y = num_heifers, linetype = season)) +
  geom_line() +
  ylim(0,600) + 
  theme_minimal() + ylab("") + 
  xlab("") + 
  ggtitle("Heifers") +
  theme(plot.title = element_text(size=22)) +
  labs(color="Calving system")

pregnant_heifers = examples %>% 
  ggplot(aes(x = step, y = num_dh, linetype = season)) +
  geom_line() +
  ylim(0,600) + 
  theme_minimal() + ylab("") + 
  xlab("") + 
  ggtitle("Pregnant heifers") +
  theme(plot.title = element_text(size=22)) +
  labs(color="Calving system")

lactating = examples %>% 
  ggplot(aes(x = step, y = num_lactating, linetype = season)) +
  geom_line() +
  ylim(0,600) + 
  theme_minimal() + ylab("") + 
  xlab("") + 
  ggtitle("Lactating") +
  theme(plot.title = element_text(size=22)) +
  labs(color="Calving system")

dry = examples %>% 
  ggplot(aes(x = step, y = num_dry, linetype = season)) +
  geom_line() +
  ylim(0,600) + 
  theme_minimal() + ylab("") + 
  xlab("") + 
  ggtitle("Dry") +
  theme(plot.title = element_text(size=22)) +
  labs(color="Calving system")






dyno <- ggarrange(calves, weaned, heifers, pregnant_heifers, lactating, dry, common.legend=TRUE) + rremove("x.text") + rremove("y.text")

dyno <- annotate_figure(dyno,
                top = text_grob("Population dynamics by herd calving system", face = "bold", size = 28),
                
                left = text_grob("Number of animals", face = "bold", size = 28, rot = 90),
                bottom = text_grob("Model step", face = "bold", size = 28),
                
                )



# Create plots of infection dynamics -----------------------------
#spring


prev <- examples %>% 
  rowwise() %>% 
  mutate(animals = num_calves + num_weaned + num_heifers + num_dh + num_lactating + num_dry) %>% 
  mutate(prev_r = 100*pop_r/animals,
         prev_s = 100*pop_s/animals,
         prev_p = 100*pop_p/animals,
         prev_rec = 100*((pop_rec_r+pop_rec_p)/animals),
         prev_car_p = 100*pop_car_p/animals,
         prev_car_r = 100*pop_car_r/animals,
         prev_clin = 100*clinical/animals) %>%
  select(step, season, prev_r, prev_s, prev_p, prev_car_p, prev_car_r, prev_clin
         , prev_rec
         ) %>% 
  pivot_longer(cols = c(
                        prev_r, 
                        prev_s, 
                        prev_p, 
                        #prev_rec,
                        prev_car_p, 
                        prev_car_r, 
                        #prev_clin
                        ), names_to = "prev", values_to = "prev_perc")%>% 
  mutate(prev = case_when(
    prev == "prev_car_p" ~ "Carrier" ,
    prev == "prev_car_r" ~ "Resistant carrier",
    prev == "prev_p" ~ "Infected",
    prev == "prev_r" ~ "Resistant infected",
    prev == "prev_s" ~ "Susceptible"#,
    #prev == "prev_rec" ~"Recovered"
  )) 


prev_plot <- prev %>% 
  ggplot(aes(x = step, y = prev_perc, colour = prev)) +
  geom_line() +
  facet_grid(vars(season)) +
  theme_minimal() +
  scale_colour_manual(values = c("#7ACCD7", "#BA2F00", "#BAC4C2", "#1AFF03", "#976533")) +
  xlab("Model step") +
  ylab("Point prevalence") +
    
  ggtitle("Infection dynamics by calving system") +
  theme(text = element_text(size = 28))  + 
  labs(colour = "Type of infection")
  



#split


#Within life stage infection dynamics 
#Spring
spring_lsd <- spring_example %>% 
  rowwise() %>% 
  mutate(
    calf_prev = 100*inf_calves/num_calves,
    weaned_prev = 100*inf_weaned/num_weaned,
    heifer_prev = 100*inf_heifers/num_heifers,
    dh_prev = 100*inf_dh/num_dh,
    lactating_prev = 100*inf_lac/num_lactating,
    dry_prev = 100*inf_dry/num_dry
  ) %>% 
  select(step, contains("prev")) %>% 
  pivot_longer(cols = contains("prev"), names_to = "ls_prev", values_to = "prev")

spring_lsd_pp <- spring_lsd %>% 
  ggplot(aes(x = step, y = prev, color = ls_prev)) +
  geom_line() +
  theme_minimal() +
  xlab("Model step") +
  ylab("Point prevalence") +
  ggtitle("spring-calving herd") +
  labs(colour = "Life stage")

#split
split_lsd <- split_example %>% 
  rowwise() %>% 
  mutate(
    calf_prev = 100*inf_calves/num_calves,
    weaned_prev = 100*inf_weaned/num_weaned,
    heifer_prev = 100*inf_heifers/num_heifers,
    dh_prev = 100*inf_dh/num_dh,
    lactating_prev = 100*inf_lac/num_lactating,
    dry_prev = 100*inf_dry/num_dry
  ) %>% 
  select(step, contains("prev")) %>% 
  pivot_longer(cols = contains("prev"), names_to = "ls_prev", values_to = "prev")

split_lsd_pp <- split_lsd %>% 
  ggplot(aes(x = step, y = prev, color = ls_prev)) +
  geom_line() +
  theme_minimal() +
  xlab("Model step") +
  ylab("Point prevalence") +
  ggtitle("split-calving herd") +
  labs(colour = "Life stage")

#batch
batch_lsd <- batch_example %>% 
  rowwise() %>% 
  mutate(
    calf_prev = 100*inf_calves/num_calves,
    weaned_prev = 100*inf_weaned/num_weaned,
    heifer_prev = 100*inf_heifers/num_heifers,
    dh_prev = 100*inf_dh/num_dh,
    lactating_prev = 100*inf_lac/num_lactating,
    dry_prev = 100*inf_dry/num_dry
  ) %>% 
  select(step, contains("prev")) %>% 
  pivot_longer(cols = contains("prev"), names_to = "ls_prev", values_to = "prev")

batch_lsd_pp <- batch_lsd %>% 
  ggplot(aes(x = step, y = prev, color = ls_prev)) +
  geom_col() +
  theme_minimal() +
  xlab("Model step") +
  ylab("Point prevalence") +
  ggtitle("batch-calving herd") +
  labs(colour = "Life stage")


#Between herd transmissions

# spring

spring_transmissions <- read_csv("./export/spring_transmissions.csv") %>% 
  filter(type != "none") %>% 
  mutate(season = "Spring")



# split

split_transmissions <- read_csv("./export/split_transmissions.csv") %>% 
  filter(type != "none") %>%
  mutate(season ="Split")

# batch

batch_transmissions <- read_csv("./export/batch_transmissions.csv") %>% 
  filter(type != "none") %>% 
  mutate(season = "Batch")


# Transmission plots



transmissions <- purrr::reduce(list(spring_transmissions, split_transmissions, batch_transmissions), dplyr::bind_rows) %>% filter(step > 365*2)

secondaries <- transmissions %>% 
  filter(type != "ee") %>% 
  group_by(season, from_id) %>% 
  summarise(infections = n_distinct(to_id)) %>% 
  ggplot(aes(y = infections, group = "season")) +
  geom_boxplot() +
  facet_wrap(vars(season)) +
  theme_minimal() +
  ylab("Number of secondary infections") +
  ggtitle("Secondary animal-to-animal infections per case") +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  scale_y_continuous(breaks = seq(0:10))

library(ggpattern)
library(magick)
trans_types <- transmissions %>% 
  group_by(season, type) %>% 
  summarise(count = n()) %>% 
  group_by(season) %>% 
  mutate(pct_of_trans = 100*count/sum(count)) %>% 
  mutate(
    "Infection mode" = case_when(
      type == "aa" ~ "Animal to animal",
      type == "cc" ~ "Calf feeding",
      type == "ee" ~"Environmental",
      type == "mm" ~ "Milking" 
    )
  ) %>% 
  ggplot(aes(x = season, y = pct_of_trans)) +
  geom_col_pattern(
    aes(
      pattern = `Infection mode`, 
      pattern_angle = `Infection mode`
    ), 
    fill            = 'white', 
    colour          = 'black',
    pattern_spacing = 0.01
  ) +
  #facet_wrap(vars(season)) +
  theme_minimal() +
  theme(axis.text.x=element_text(angle=45,hjust=1)) +
  xlab("Calving system") +
  ylab("Number of transmission events") +
  ggtitle("Types of transmission by calving system") 
  



ls_types <- transmissions %>% 
  mutate(
    type = case_when(
      type == "aa" ~ "Animal to animal",
      type == "cc" ~ "Calf feeding",
      type == "ee" ~"Environmental",
      type == "mm" ~ "Milking" 
    )
  ) %>% 
  mutate(
    stage = case_when(
      stage == 1 ~ "Calf",
      stage == 2 ~ "Weaned",
      stage == 3 ~ "Heifer",
      stage == 4 ~ "Pregnant heifer",
      stage == 5 ~ "Lactating",
      stage == 6 ~ "Dry"
    )
  ) %>% 
  mutate(stage = as.factor(stage)) %>% 
  mutate(stage = fct_relevel(stage, "Calf", "Weaned", "Heifer", "Pregnant heifer", "Lactating", "Dry")) %>% 
  group_by(season, stage, type) %>% 
  summarise(count = n()) %>% 
  mutate(pct_trans = 100*count/sum(count)) %>% 
  rename('Infection mode' = type) %>% 
  ggplot(aes(x = as.factor(stage), y = count)) +
  geom_col_pattern(
    aes(
      pattern = `Infection mode`, 
      pattern_angle = `Infection mode`
    ), 
    fill            = 'white', 
    colour          = 'black',
    pattern_spacing = 0.02
  ) +
  facet_wrap(vars(season)) +
  theme_minimal() +
  scale_fill_viridis_d() +
  xlab("Life stage") +
  theme(axis.text.x=element_text(angle=45,hjust=1)) +
  ylab("Number of transmission events") +
  ggtitle("Transmission types per life stage") +
  labs(fill = "Type of transmission")


# Detailed infection dynamics
#Estimate r0 using simple method as age at infection over average life expectancy

spring_infections <- read_csv("./export/spring_infections.csv") %>% mutate(season = "spring")
split_infections <- read_csv("./export/split_infections.csv") %>% mutate(season = "split")
batch_infections <- read_csv("./export/batch_infections.csv") %>% mutate(season = "batch")

all_infections <- reduce(list(spring_infections, split_infections, batch_infections), bind_rows) %>% 
  mutate(id = paste0(id,season)) %>% filter(step > 365*2 & step <= 2555)

alive_at_end <- all_infections %>% filter(step == max(step))
`%notin%` <- Negate(`%in%`)

# culled_in_model <- all_infections %>% 
#   filter(age != 0) %>% 
#   group_by(id) %>% 
#   mutate(age_at_cull = max(age)) %>% 
#   filter(id %notin% alive_at_end$id ) %>% 
#   distinct(id, season, age_at_cull) %>% 
#   # exclude bobby calves
#   filter(age_at_cull > 5)

culled_in_model <- all_infections %>% 
                      filter(!is.na(cull_reason)) %>% 
                      mutate(age_at_cull = age) %>% 
                      filter(cull_reason != "bobby") %>% 
                      distinct(id, season, age_at_cull)

average_life_expectancy =   culled_in_model %>% group_by(season) %>% summarise(life_expectancy = median(age_at_cull))

# Determine average age at infection

age_at_inf <- all_infections %>% 
                filter(status == 1 | status == 2) %>% 
               # filter(clin == TRUE) %>% 
                group_by(season, id) %>% 
                mutate(age_at_infection = min(age)) %>%  
                filter(stage != 1) %>% 
                select(season, id, age_at_infection)

average_age_at_infection = age_at_inf %>% group_by(season) %>% summarise(age_at_inf = mean(age_at_infection))

rnought = left_join(average_life_expectancy, average_age_at_infection, by = 'season') %>% 
            mutate(r0 = life_expectancy/age_at_inf) %>% 
            mutate(life_expectancy = round(life_expectancy)) %>% 
            mutate(age_at_inf = round(age_at_inf)) %>% 
            mutate(r0 = round(r0, digits =2)) %>% 
            kable(format = "latex")

#By stock group

rnought = function(stage){
  
  tar <- all_status %>% 
    filter(stage == !!stage) %>% 
    group_by(id) %>% 
    summarise(entered = min(age),
              left = max(age)) %>% 
    mutate(tar = left - entered) %>% 
    filter(tar != 3) %>% 
    distinct(id, tar)
  
  average_tar = mean(tar$tar)
  
  age_at_inf <- all_status %>% 
    filter(status == 1 | status == 2) %>% 
    group_by(id) %>% 
    mutate(age_at_infection = min(age)) %>%  
    filter(stage == !!stage) %>% 
    distinct(id, age_at_infection)
  
  average_age_at_infection = mean(age_at_inf$age_at_infection)
  
  rnought = average_life_expectancy/average_tar
  
  return(rnought)
  
  
}

# Determine culling per stock group

all_infections %>% 
  filter(age !=0) %>% 
  filter(id %notin% alive_at_end$id) %>% 
  group_by(season, id) %>% 
  mutate(age_at_cull = max(age)) %>% 
  distinct(id, season, status, age_at_cull, stage) %>% 
  filter(age_at_cull > 100) %>% 
  group_by(season, stage) %>% 
  summarise(count = n()) %>% 
  group_by(season) %>% 
  mutate(count = 100*count/sum(count)) %>% 
  ggplot(aes(x = season, y = count, fill = as.factor(stage))) +
  geom_col() +
  theme_minimal() +
  scale_fill_viridis_d() +
  xlab("Calving system") +
  theme(axis.text.x=element_text(angle=45,hjust=1)) +
  ylab("Percentage of culls and mortalities") +
  ggtitle("Culling and mortality by calving system") +
  labs(fill = "Life stage")

all_infections %>% 
  filter(status == 1 | status ==2) %>% 
  filter(clin == TRUE ) %>% 
  filter(stage >= 3) %>% 
  group_by(season, step) %>% 
  summarise(count = n()) %>% 
  ggplot(aes(x = step, y = count)) + 
  geom_col() +
  facet_wrap(vars(season))
    

# Average duration of infection

days_infected <- all_infections %>% 
  filter(days_inf != 0) %>% 
  group_by(id) %>% 
  filter(days_inf == max(days_inf))

# Determine beta

# For animal to animal transmissions

all_animal <-  transmissions %>% 
       # rowwise() %>% 
        mutate(tid = paste0(step, from_id, to_id, season)) %>% 
        group_by(tid) %>% 
        mutate(nobs = length(tid)) %>% 
        mutate(duplicate = ifelse(nobs > 1 & effective == FALSE, "cull", "keep")) %>% 
        filter(duplicate == "keep") %>% 
        mutate(type = ifelse(type == "cc" | type == "aa" | type == "mm", "aa", type)) %>% 
        group_by(type, effective) %>% 
        summarise(count = n()) %>% 
        pivot_wider(
          names_from = effective, 
          values_from = count,
          id_cols = type
        ) %>% 
    mutate(transmission_prob = `TRUE`/(`TRUE`+`FALSE`))

clinical <- transmissions %>% 
  # rowwise() %>% 
  mutate(tid = paste0(step, from_id, to_id, season)) %>% 
  group_by(tid) %>% 
  mutate(nobs = length(tid)) %>% 
  mutate(duplicate = ifelse(nobs > 1 & effective == FALSE, "cull", "keep")) %>% 
  filter(duplicate == "keep") %>% 
  mutate(type = ifelse(type == "cc" | type == "aa" | type == "mm", "aa", type)) %>% 
  filter(type == "aa" & clinical == "TRUE") %>% 
  group_by(type, effective) %>% 
  summarise(count = n()) %>% 
  pivot_wider(
    names_from = effective, 
    values_from = count,
    id_cols = type
  ) %>% 
  mutate(transmission_prob = `TRUE`/(`TRUE`+`FALSE`))

subclinical <- transmissions %>% 
  # rowwise() %>% 
  filter(type != "ee") %>% 
  mutate(tid = paste0(step, from_id, to_id, season)) %>% 
  group_by(tid) %>% 
  mutate(nobs = length(tid)) %>% 
  mutate(duplicate = ifelse(nobs > 1 & effective == FALSE, "cull", "keep")) %>% 
  filter(duplicate == "keep") %>% 
  mutate(type = ifelse(type == "cc" | type == "aa" | type == "mm", "aa", type)) %>% 
  filter(type == "aa" & clinical == "FALSE") %>% 
  group_by(type, effective) %>% 
  summarise(count = n()) %>% 
  pivot_wider(
    names_from = effective, 
    values_from = count,
    id_cols = type
  ) %>% 
  mutate(transmission_prob = `TRUE`/(`TRUE`+`FALSE`))

# Rates of resistance

# Resist system

 examples %>% 
   rowwise() %>% 
   mutate(animals = num_calves + num_weaned + num_heifers + num_dh + num_lactating + num_dry) %>% 
   mutate(prev_r = 100*(pop_r + pop_car_r)/animals) %>% 
   select(season, prev_r) %>% 
   ggplot(aes(y = prev_r)) +
   geom_boxplot() +
   facet_wrap(vars(season)) +
   theme_minimal() +
   ylab("Point prevalence (%)") +
   ggtitle("Daily point prevalence of resistant infections by calving system") +
   theme(axis.title.x=element_blank(),
         axis.text.x=element_blank(),
         axis.ticks.x=element_blank())

   
# Resist ls
 
 all_infections %>% 
   select(step, season, stage, status) %>% 
   group_by(step, season, stage, status) %>%
   summarise(count = n()) %>% 
   group_by(step, season, stage) %>% 
   mutate(animals = sum(count)) %>% 
   mutate(resist = sum(count[which(status == 2 | status == 6)])) %>% 
   distinct(step, season, animals, resist) %>% 
   mutate(prev_resist = 100*resist/animals) %>% 
   mutate(stagename = case_when(
     stage == 1 ~ "Calves",
     stage == 2 ~ "Weaned",
     stage == 3 ~ "Heifers",
     stage == 4 ~ "Pregnant heifers",
     stage == 5 ~ "Lactating",
     stage == 6 ~ "Dry"
   )) %>% 
   #mutate(stage = fct_relevel(stage, c("Calves", "Weaned", "Heifers", "Pregnant heifers", "Lactating", "Dry"))) %>% 
   ggplot(aes(y = prev_resist)) +
    geom_boxplot() +
    facet_wrap(vars(fct_reorder(stagename, stage)))  +
   theme_minimal() +
   ylab("Point prevalence (%)") +
   ggtitle("Point prevalence of resistance by life stage") +
   theme(axis.title.x=element_blank(),
         axis.text.x=element_blank(),
         axis.ticks.x=element_blank())
   
 #Prop resist system
 
 all_infections %>% 
   select(step, season, status) %>% 
   group_by(step, season, status) %>%
   summarise(count = n()) %>% 
   group_by(step, season) %>% 
   mutate(infected = sum(count[which(status == 2 | status == 6 | status == 1 | status == 5)])) %>% 
   mutate(resist = sum(count[which(status == 2 | status == 6)])) %>% 
   distinct(step, season, infected, resist) %>% 
   mutate(perc_resist = 100*resist/infected) %>% 
   mutate(season = case_when(
     season == "batch" ~ "Batch",
     season == "split" ~ "Split",
     season == "spring" ~ "Spring"
   )) %>% 
   ggplot(aes(y = perc_resist)) +
   geom_boxplot() +
   facet_wrap(vars(season))  +
   theme_minimal() +
   ylab("Percentage of infections resistant") +
   ggtitle("Percentage of resistant infections by calving system") +
   theme(axis.title.x=element_blank(),
         axis.text.x=element_blank(),
         axis.ticks.x=element_blank())
 
 all_infections %>% 
   select(step, season, status) %>% 
   group_by(step, season, status) %>%
   summarise(count = n()) %>% 
   group_by(step, season) %>% 
   mutate(infected = sum(count[which(status == 2 | status == 6 | status == 1 | status == 5)])) %>% 
   mutate(resist = sum(count[which(status == 2 | status == 6)])) %>% 
   distinct(step, season, infected, resist) %>% 
   mutate(perc_resist = 100*resist/infected) %>% 
   ungroup() %>% 
   summary(perc_resist)

 
 # Median prevalence of samlmonella

  examples %>% 
   rowwise() %>% 
   mutate(animals = num_calves + num_weaned + num_heifers + num_dh + num_lactating + num_dry) %>% 
   mutate(prev_r = 100*pop_r/animals,
          prev_s = 100*pop_s/animals,
          prev_p = 100*pop_p/animals,
          prev_rec = 100*((pop_rec_r+pop_rec_p)/animals),
          prev_car_p = 100*pop_car_p/animals,
          prev_car_r = 100*pop_car_r/animals,
          prev_clin = 100*clinical/animals,
          prev = 100*(pop_r+pop_p+pop_car_r+pop_car_p)/animals,
          prev_all_r = 100*(pop_r+pop_car_r)/animals,
          prev_res_inf = 100*(pop_r+pop_car_r)/(pop_p+pop_car_p+pop_r+pop_car_r)) %>% 
    summary(prev)
  
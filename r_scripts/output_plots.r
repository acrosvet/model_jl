
source("./r_scripts/libraries.r")
library(lubridate)
#library(htmlwidgets)
# Import the model run from the animalModel
run <- read_csv("/home/alex/Documents/julia_abm/model_jl/export/seasonal_model_run.csv") %>%
        janitor::clean_names()


# GGPLOT static plots of infection------------------------------------------------

run %>% 
  mutate(day = lubridate::ymd(day)) %>%
  group_by(day, animal_status) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = day, y = count, colour =animal_status)) +
  geom_line()


# Faceted plot of farm runs 


 run %>%  
  filter(!is.na(AnimalID)) %>%
  mutate(Day = lubridate::ymd(Day)) %>%
  filter(Day >= "2021-07-02") %>%
  group_by(Day, FarmID, AnimalStage) %>% 
  summarise(count = n()) %>% 
  ggplot(aes(x = Day, y = count)) +
  geom_line(aes(colour  = factor(AnimalStage))) +
  facet_wrap(~FarmID, nrow = 100)


# Generate a ploot of population dynamics over time
p <- run %>%  
  filter(!is.na(AnimalID)) %>%
  mutate(Day = lubridate::ymd(Day)) %>%
  filter(Day >= "2021-07-02") %>%
  group_by(Day, AnimalStage) %>% 
  summarise(count = n()) %>% 
  pivot_wider(names_from = AnimalStage, values_from = count) %>% 
  plot_ly() %>% 
  add_trace(x = ~Day, y = ~L, type = 'bar', name = 'Milkers') %>% 
  add_trace(x = ~Day, y = ~D, type = 'bar', name = 'Dry') %>% 
  add_trace(x = ~Day, y = ~C, type = 'bar', name = 'Calves') %>%
  add_trace(x = ~Day, y = ~H, type = 'bar', name = 'Heifers') %>%
  add_trace(x = ~Day, y = ~DH, type = 'bar', name = 'Preg. Heifers') %>%
  add_trace(x = ~Day, y = ~W, type = 'bar', name = 'Weaned') %>%
  layout(barmode = 'stack', 
  title = "Seasonally Calving Farm (Spring)",
  yaxis = list(title = "Number of animals"),
  xaxis = list(title = "Date"))


htmlwidgets::saveWidget(p, "./export/Seasonally Calving Herds.html", selfcontained = F, libdir = "lib")

run %>%  
  mutate(Day = ModelStep) %>%
  group_by(Day, AnimalStage) %>% 
  summarise(count = n()) %>% 
  pivot_wider(names_from = AnimalStage, values_from = count) %>% 
  plot_ly() %>% 
  add_trace(x = ~Day, y = ~L, type = 'bar', name = 'Milkers') %>% 
  add_trace(x = ~Day, y = ~D, type = 'bar', name = 'Dry') %>% 
  add_trace(x = ~Day, y = ~C, type = 'bar', name = 'Calves') %>%
  add_trace(x = ~Day, y = ~H, type = 'bar', name = 'Heifers') %>%
  add_trace(x = ~Day, y = ~DH, type = 'bar', name = 'Preg. Heifers') %>%
  add_trace(x = ~Day, y = ~W, type = 'bar', name = 'Weaned') %>%
  layout(barmode = 'stack', 
  title = "Seasonally Calving Farm (Spring)",
  yaxis = list(title = "Number of animals"),
  xaxis = list(title = "Date"))

status <- run %>%
            filter(ModelStep != 0) %>%
            group_by(ModelStep, AnimalStatus) %>%
            summarise(count = n()) %>%
            pivot_wider(names_from = AnimalStatus, values_from = count)

bactopop <- run %>%
              plot_ly(x = ~step) %>%
              add_trace(y = ~AnimalBactoPop_r, color = ~AnimalID) 

summary(run$AnimalBactoPop_r)
summary(run$AnimalBactoPop_is)


source("./r_scripts/libraries.r")
library(lubridate)
#library(htmlwidgets)
# Import the model run from the animalModel
run <- read_csv("/home/alex/Documents/julia_abm/model_jl/export/seasonal_model_run.csv")



# Generate a ploot of population dynamics over time
p <- run %>%  
  mutate(Day = lubridate::ymd(Day)) %>%
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
            group_by(ModelStep, AnimalStatus) %>%
            summarise(count = n()) %>%
            pivot_wider(names_from = AnimalStatus, values_from = count)

bactopop <- run %>%
              plot_ly(x = ~step) %>%
              add_trace(y = ~AnimalBactoPop_r, color = ~AnimalID) 

summary(run$AnimalBactoPop_r)
summary(run$AnimalBactoPop_is)

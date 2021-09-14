
source("./r_scripts/libraries.r")
library(lubridate)
# Import the model run from the animalModel
run <- read_csv("/home/alex/Documents/julia_abm/model_jl/export/continuous_model_run.csv")

# Generate a ploot of population dynamics over time
run %>%  
 #filter(CalvingSeason == "Spring") %>%
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
  layout(barmode = 'stack', title = "Spring")

run %>% filter(AgentType == "Joined")

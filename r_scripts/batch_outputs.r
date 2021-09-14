
source("./r_scripts/libraries.r")
library(lubridate)
# Import the model run from the animalModel
run <- read_csv("/home/alex/Documents/julia_abm/model_jl/export/batch_model_run.csv")

# Generate a ploot of population dynamics over time
p <- run %>%  
 #filter(CalvingSeason == "Spring") %>%
  mutate(Day = lubridate::ymd(Day)) %>%
  mutate(Year = year(Day)) %>%
  #filter(Year == "2026") %>%
#  filter(CalvingSeason == "B4") %>%
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
  title = "Batch Calving Herd (Four Batches)",
  yaxis = list(title = "Number of animals"),
  xaxis = list(title = "Date"))

  htmlwidgets::saveWidget(p, "./export/Batch Calving Herds.html", selfcontained = F, libdir = "lib")


# Inspect what is happening with B2

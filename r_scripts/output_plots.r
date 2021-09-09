
# Import the model run from the animalModel
run <- read_csv("/home/alex/Documents/julia_abm/model_jl/export/animal_model_run.csv")

# Generate a ploot of population dynamics over time
run %>% 
  filter(AnimalStage != 0) %>% 
  group_by(ModelStep, AnimalStage) %>% 
  summarise(count = n()) %>% 
  pivot_wider(names_from = AnimalStage, values_from = count) %>% 
  plot_ly() %>% 
  add_trace(x = ~ModelStep, y = ~L, type = 'bar', name = 'L') %>% 
  add_trace(x = ~ModelStep, y = ~D, type = 'bar', name = 'D') %>% 
  layout(barmode = 'stack')

# Inspect in calf rates  
icr = run %>% 
  filter(AnimalStage != 0) %>% 
  group_by(ModelStep, AnimalStage) %>% 
  summarise(count = n()) %>% 
  pivot_wider(names_from = AnimalStage, values_from = count) %>% 
  mutate(per_calved = 100*(L/(D+L)))

  
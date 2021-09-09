
# Import the model run from the animalModel
run <- read_csv("/home/alex/Documents/julia_abm/model_jl/export/animal_model_run.csv")

tmp = run %>% filter(DIM > 280)

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

  run %>% 
  filter(AnimalStage != 0) %>% 
  group_by(ModelStep, AnimalStage) %>% 
  summarise(count = n()) %>% 
  pivot_wider(names_from = AnimalStage, values_from = count) %>% 
  plot_ly() %>% 
  add_trace(x = ~ModelStep, y = ~H, type = 'bar', name = 'H') %>% 
  add_trace(x = ~ModelStep, y = ~DH, type = 'bar', name = 'DH') %>% 
  layout(barmode = 'stack')

  run %>% 
    mutate(Day = lubridate::ymd(Day)) %>%
    filter(AnimalStage != 0) %>% 
    group_by(Day, PregStat) %>% 
    summarise(count = n()) %>% 
    pivot_wider(names_from = PregStat, values_from = count) %>% 
    plot_ly() %>% 
    add_trace(x = ~Day, y = ~E, type = 'bar', name = 'E') %>% 
    add_trace(x = ~Day, y = ~P, type = 'bar', name = 'P') %>% 
    layout(barmode = 'stack')


      run %>% 
        mutate(Day = lubridate::ymd(Day)) %>%
        filter(AnimalStage != 0) %>% 
        group_by(Day, AnimalStage) %>% 
        summarise(count = n()) %>% 
        pivot_wider(names_from = AnimalStage, values_from = count) %>% 
        plot_ly() %>% 
        add_trace(x = ~Day, y = ~H, type = 'bar', name = 'H') %>% 
        add_trace(x = ~Day, y = ~DH, type = 'bar', name = 'DH') %>% 
        layout(barmode = 'stack')

# Inspect in calf rates  
icr = run %>% 
  filter(AnimalStage != 0) %>% 
  group_by(ModelStep, AnimalStage) %>% 
  summarise(count = n()) %>% 
  pivot_wider(names_from = AnimalStage, values_from = count) %>% 
  mutate(per_calved = 100*(L/(D+L)))

# Calving by msd

run %>%
  filter()

# Inspect the ages of heifers

heifers <- run %>%
            #filter(AnimalStage == "H") %>%
            mutate(Day = lubridate::ymd(Day)) %>%
            mutate(msd = lubridate::ymd(msd)) %>%
            filter(Day == msd) %>%
            filter(AnimalStage == "DH")

write_csv(heifers, "./export/heifers.csv")

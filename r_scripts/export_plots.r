# Generate plots of farm dynamics over time ----------
commencify <- proc.time()

install.packages("tidyverse")
library(tidyverse)

run <- read_csv("./data/gpfs/projects/punim0549/acrosbie/model_jl/export/seasonal_model_run.csv")


# Faceted plot of farm runs 


populations <-  run %>%  
                    filter(!is.na(AnimalID)) %>%
                    mutate(Day = lubridate::ymd(Day)) %>%
                    filter(Day >= "2021-07-02") %>%
                    group_by(Day, FarmID, AnimalStage) %>% 
                    summarise(count = n()) %>% 
                    ggplot(aes(x = Day, y = count)) +
                    geom_line(aes(colour  = factor(AnimalStage))) +
                    facet_wrap(~FarmID, nrow = 100)

ggsave("./data/gpfs/projects/punim0549/acrosbie/model_jl/export/populations.png", populations)


infections <-  run %>%  
                    filter(!is.na(AnimalID)) %>%
                    mutate(Day = lubridate::ymd(Day)) %>%
                    filter(Day >= "2021-07-02") %>%
                    group_by(Day, FarmID, AnimalStatus) %>% 
                    summarise(count = n()) %>% 
                    ggplot(aes(x = Day, y = count)) +
                    geom_line(aes(colour  = factor(AnimalStatus))) +
                    facet_wrap(~FarmID, nrow = 100)

ggsave("./data/gpfs/projects/punim0549/acrosbie/model_jl/infections.png", infections)

endify <- proc.time() - commencify

return(endify)
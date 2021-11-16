options(bitmapType='cairo')

# Generate plots of farm dynamics over time ----------
commencify <- proc.time()

#install.packages("tidyverse")
library(tidyverse)

run <- read_csv("./export/seasonal_model_run.csv")


# Faceted plot of farm runs

for (i in 1:length(unique(run$FarmID))) {
populations <-  run %>%
                    filter(FarmID == !!i) %>%
                    filter(!is.na(AnimalID)) %>%
                    mutate(Day = lubridate::ymd(Day)) %>%
                    filter(Day >= "2021-07-02") %>%
                    group_by(Day, FarmID, AnimalStage) %>%
                    summarise(count = n()) %>%
                    ggplot(aes(x = Day, y = count)) +
                    geom_line(aes(colour  = factor(AnimalStage))) 

ggsave(paste0("./export/populations_farm_",i,".png"))
}

for (i in 1:length(unique(run$FarmID))) {
infections <-  run %>%
                    filter(FarmID == !!i) %>%
                    filter(!is.na(AnimalID)) %>%
                    mutate(Day = lubridate::ymd(Day)) %>%
                    filter(Day >= "2021-07-02") %>%
                    group_by(Day, FarmID, AnimalStatus) %>%
                    summarise(count = n()) %>%
                    ggplot(aes(x = Day, y = count)) +
                    geom_line(aes(colour  = factor(AnimalStatus))) 

ggsave(paste0("./export/infections_farm_",i,".png"))
}

endify <- proc.time() - commencify

endify




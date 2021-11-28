library(tidyverse)
library(plotly)

na_data <- read_csv("./export/animal_na.csv")

na_data %>%
    plot_ly(x = ~step) %>%
        add_trace(y = ~num_calves, name = 'calves', type = 'bar') %>%
        add_trace(y = ~num_weaned, name = 'weaned', type = 'bar') %>%
        add_trace(y = ~num_heifers, name = 'heifers', type = 'bar') %>%
        add_trace(y = ~num_dh, name = 'dh', type = 'bar') %>%
        add_trace(y = ~num_lactating, name = 'lactating', type = 'bar') %>%
        add_trace(y = ~num_dry, name = 'dry', type = 'bar') %>%
        layout(barmode = 'stack')

na_data %>%
    plot_ly(x = ~step) %>%
    add_trace(y = ~pop_r, name = 'Resistant', type = 'bar') %>%
    add_trace(y = ~pop_car_r, name = 'Carrier R', type = 'bar') %>%
    add_trace(y = ~pop_rec_r, name = 'Recovered R', type = 'bar') %>%
    layout(barmode = 'stack')

#Examine the total data output

all_data <- read_csv("./export/all_na.csv")

#Days exposed not incrementing

de <- all_data %>%
    filter(days_exposed != 0)

di <- all_data %>%
        filter(days_infected != 0)

exp <- all_data %>%
            filter(status == 4)

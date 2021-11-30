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
    add_trace(y = ~pop_rec_p, name = 'Recovered P', type = 'bar') %>%
    add_trace(y = ~pop_p, name = 'Sensitive', type = 'bar') %>%
    add_trace(y = ~pop_car_p, name = 'Carrier S', type = 'bar') %>%
    layout(barmode = 'stack')

#Examine the total data output

all_data <- read_csv("./export/all_na.csv")


statuses <- all_data %>% 
group_by(date, status) %>%
summarise(count = n()) %>%
pivot_wider(names_from = status, values_from = count) %>%
mutate(across(where(is.numeric), replace_na, replace = 0))


statuses %>%
    plot_ly(x = ~date) %>%
    add_trace(y = ~`0`, name = 'susceptible') %>%
    #add_trace(y = ~`5`, name = 'cp') %>%
    add_trace(y = ~`6`, name = 'cr') %>%
    add_trace(y = ~`2`, name = 'r') %>%
    add_trace(y = ~`4`, name = 'er') %>%
    add_trace(y = ~`8`, name = 'rr')
    #Days exposed not incrementing

de <- all_data %>%
    filter(days_exposed != 0)

di <- all_data %>%
        filter(days_infected != 0)

exp <- all_data %>%
            filter(status == 4)

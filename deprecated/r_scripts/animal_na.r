library(tidyverse)
library(plotly)

na_data <- read_csv("./export/animal_na.csv")

na_data %>%
    plot_ly(x = ~step) %>%
        add_trace(y = ~num_calves, name = 'Calves', type = 'bar') %>%
        add_trace(y = ~num_weaned, name = 'Weaned', type = 'bar') %>%
        add_trace(y = ~num_heifers, name = 'Heifers', type = 'bar') %>%
        add_trace(y = ~num_dh, name = 'Joined heifers', type = 'bar') %>%
        add_trace(y = ~num_lactating, name = 'Lactating', type = 'bar') %>%
        add_trace(y = ~num_dry, name = 'Dry Cows', type = 'bar') %>%
        layout(
            title = "5-year reproductive dynamics - Spring calving herd",
            xaxis = list(title = 'Simulation date'),
            yaxis = list(title = 'Number of animals'),
            barmode = 'stack')

na_data %>%
    plot_ly(x = ~step) %>%
    add_trace(y = ~pop_r, name = 'Resistant', type = 'bar') %>%
    add_trace(y = ~pop_car_r, name = 'Resistant Carrier', type = 'bar') %>%
    add_trace(y = ~pop_rec_r, name = 'Recovered Resistant', type = 'bar') %>%
    add_trace(y = ~pop_rec_p, name = 'Recovered Sensitive', type = 'bar') %>%
    add_trace(y = ~pop_p, name = 'Sensitive', type = 'bar') %>%
    add_trace(y = ~pop_car_p, name = 'Sensitive Carrier', type = 'bar') %>%
    layout(barmode = 'stack',
    title  = '10 year infection dynamics: Spring herd (70% VR @ 60% efficacy)',
    xaxis = list(title = 'Simulation date'), 
    yaxis = list(title = 'Number of animals'))

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
    add_trace(y = ~`1`, name = 'infected pathogenic') %>%
    add_trace(y = ~`5`, name = 'carrier pathogenic') %>%
    #add_trace(y = ~`6`, name = 'carrier resistant') %>%
    #add_trace(y = ~`2`, name = 'infected resistant') %>%
    #add_trace(y = ~`4`, name = 'exposed resistant') %>%
    add_trace(y = ~`3`, name = 'exposed pathogenic') %>%
    add_trace(y = ~`7`, name = 'recovered pathogenic') #%>%

    #add_trace(y = ~`8`, name = 'recovered resistant')
    #Days exposed not incrementing

de <- all_data %>%
    filter(days_exposed != 0)

di <- all_data %>%
        filter(days_infected != 0)

exp <- all_data %>%
            filter(status == 4)

library(ggplot2)

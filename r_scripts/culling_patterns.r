source("./r_scripts/libraries.r")

culling <- read_csv("./export/seasonal_culling.csv")

summary(culling)

fig <- culling %>%
group_by(reason) %>%
summarise(count = n()) %>%
plot_ly(
x = ~reason,
y = ~count) %>%
layout(
    title = "Seasonal herd model culling",
    xaxis = list(title = "Number of animals"),
    yaxis = list(title = "Culling reason")
)

  htmlwidgets::saveWidget(fig, "./export/Seasonal cullign reason.html", selfcontained = F, libdir = "lib")


culling %>%
plot_ly(y = ~dim, color = ~reason, type = 'box')

contacts <- read_csv("./export/seasonal_contacts.csv") 

effective_contact <- contacts %>% filter(contact_id != "No contact" & contact_id != 0)

hist(effective_contact$number_contacted)

ecr <- effective_contact %>%
    plot_ly() %>%
    add_trace(y = ~number_contacted, type = 'box', color = ~agent_stage) %>%
    layout(title = "Daily contacts by stock class", xaxis = list(title = "Stock class"), yaxis = list("Number contacted"))

  htmlwidgets::saveWidget(ecr, "./export/Seasonal contacts.html", selfcontained = F, libdir = "lib")



contact_outcome <- contacts %>%  
                        filter(Day != 0) %>%
                        mutate(Day = lubridate::ymd(Day)) %>%
                        filter(Day <= "2022-07-02") %>%
                        group_by(outcome) %>%
                        summarise(count = n()) %>%
                        plot_ly(x = ~outcome, y = ~count, color = ~outcome) %>%
                        layout(title = "Animal contacts, 2021/22",
                        xaxis = list(title = "Contact outcome"),
                        yaxis = list(title = "Number of events"))
contact_outcome

  htmlwidgets::saveWidget(contact_outcome, "./export/Seasonal contacts.html", selfcontained = F, libdir = "lib")

names(contacts)

tmp <- contacts %>%
    filter(Day != 0) %>%
    group_by(Day, outcome) %>%
    summarise(count = n()) %>%
    pivot_wider(names_from = outcome, values_from = count) %>%
    plot_ly(x = ~Day) %>%
    add_trace(y = ~`Neither infected`, name = "None inf.") %>%
    add_trace(y = ~`Transmission to agent!`, name = "Trans. to") 

run <- read_csv("./export/seasonal_model_run.csv")

infection_dynamics <- run %>%
    filter(Day != 0) %>%
    group_by(Day, AnimalStatus) %>%
    summarise(count = n()) %>%
    pivot_wider(names_from = AnimalStatus, values_from = count) %>%
    plot_ly(x = ~Day) %>%
        add_trace(y = ~IR, name = "Inf. res") %>%
        add_trace(y = ~IS, name = "Inf. sens") %>%
        add_trace(y = ~S, name = "Suscep.") %>%
        add_trace(y = ~ES, name = "Exp. sens.") %>%
        add_trace(y = ~recovered, name = "Recovered") %>%
        add_trace(y = ~carrier_resistant, name = "Car. res.")%>%
        add_trace(y = ~carrier_sensitive, name = "Car. Sens.")  

  htmlwidgets::saveWidget(infection_dynamics, "./export/Seasonal infection dynamics.html", selfcontained = F, libdir = "lib")

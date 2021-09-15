source("./r_scripts/libraries.r")

culling <- read_csv("./export/seasonal_culling.csv")

summary(culling)

culling %>%
group_by(reason) %>%
summarise(count = n()) %>%
plot_ly(
x = ~reason,
y = ~count)

culling %>%
plot_ly(y = ~dim, color = ~reason, type = 'box')

contacts <- read_csv("./export/seasonal_contacts.csv") 

effective_contact <- contacts %>% filter(contact_id != "No contact" & contact_id != 0)

hist(effective_contact$number_contacted)

contact_outcome <- effective_contact %>%   
                        group_by(outcome) %>%
                        summarise(count = n()) %>%
                        plot_ly(x = ~outcome, y = ~count, color = ~outcome)
contact_outcome
names(contacts)

tmp <- contacts %>%
    filter(Day != 0) %>%
    group_by(Day, outcome) %>%
    summarise(count = n()) %>%
    pivot_wider(names_from = outcome, values_from = count) %>%
    plot_ly(x = ~Day) %>%
    add_trace(y = ~`Neither infected`, name = "None inf.") %>%
    add_trace(y = ~`Transmission to agent!`, name = "Trans. to") 

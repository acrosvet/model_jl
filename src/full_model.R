#Analyse full farm  model =======================================================

#Load libs
library(tidyverse)
library(plotly)
library(network)

#Import the movement data ------------------------------------------------------

farm_movements <- read_csv("./export/sensitivity/full/farm_run_movements_1.csv")
farm_movements_2 <- read_csv("./export/sensitivity/full/farm_run_movements_2.csv")

farm_movements <- bind_rows(farm_movements, farm_movements_2)

#Import the transmissions file--------------------------------------------------

farm_transmissions <- read_csv("./export/sensitivity/full/farm_run_statuses_1.csv") %>% mutate(farm = paste0(farm, "run1"))
farm_transmissions_2 <- read_csv("./export/sensitivity/full/farm_run_statuses_2.csv")%>% mutate(farm = paste0(farm, "run2"))

farm_transmissions <- bind_rows(farm_transmissions, farm_transmissions_2)

#Create a numeric days elapsed variable ----------------------------------------

first_resistance <- farm_transmissions %>% 
                        filter(date != "0-01-01") %>% 
                        mutate(day = date - min(date)) %>%  
                        mutate(day = as.numeric(day))

#Import the parameter file -----------------------------------------------------

params <- read_csv("./export/sensitivity/full/parameters/sensitivity_args_1.csv") %>% rename(original_status = status)
params_2 <- read_csv("./export/sensitivity/full/parameters/sensitivity_args_2.csv") %>% rename(original_status = status)

#Append this to the transmission data

complete_transmissions <- left_join(first_resistance, params, by = c("farm" = "farm"))

#View farms that changed status over time

changed_status <- complete_transmissions %>% filter(original_status != status)

#Generate a simple survival plot of the time taken to first resistance




library(survival)
first_resistance$farm = as.factor(first_resistance$farm)
resist_surv <- Surv(time = first_resistance$day, event = first_resistance$status == 2)
summary(resist_surv)

carrier_r.km <- survfit(Surv(time = first_resistance$day, event = first_resistance$status == 2), conf.type = "none", type =
                          "kaplan-meier", data = first_resistance)
plot(carrier_r.km, xlab = "Model day", ylab = "S(t)", main = "Days to first resistance")

kmfit <- survfit(resist_surv ~ complete_transmissions$calving_system)

plot(kmfit, lty = c("solid", "dashed", "dotdash"), col = c("black", "grey", "blue"), xlab = "Days", ylab = "Survival Probabilities", main = "Days until first resistance")

legend("bottomleft", c("Spring", "Split", "Batch"), lty = c("solid", "dashed", "dotdash"), col = c("black", "grey", "blue"))


model_fit <-Surv(time = first_resistance$day, event = first_resistance$status == 2)

autoplot(model_fit) + 
  labs(x = "\n Survival Time (Days) ", y = "Survival Probabilities \n", 
       title = "Time until resistance") + 
  theme(plot.title = element_text(hjust = 0.5), 
        axis.title.x = element_text(face="bold", colour="#FF7A33", size = 12),
        axis.title.y = element_text(face="bold", colour="#FF7A33", size = 12),
        legend.title = element_text(face="bold", size = 10))

# Import the network structure 

#Plot the initial status of the farms
nodes <- read_csv("./export/sensitivity/full/farm_run_space_1.csv")
nodes <- nodes %>% rowid_to_column("id")
nodes = left_join(nodes, params, by = c("id" = "farm")) %>% select(id, src, dst, group = original_status, value = optimal_stock)

per_route <- farm_movements %>% 
                filter(from != 0) %>% 
                group_by(from, to) %>% 
                summarise(weight = n()) %>% 
                ungroup()

edges <- per_route

library(visNetwork)
library(networkD3)

 visNetwork(nodes, edges)

 #Plot the final status of the farms
 nodes <- read_csv("./export/sensitivity/full/farm_run_space_1.csv") 
 nodes <- nodes %>% rowid_to_column("id")
 final_status = farm_transmissions %>% filter(date == max(date))%>% select(farm, status) %>% left_join(params)
 nodes = left_join(nodes, final_status, by = c("id" = "farm")) %>% select(id, src, dst, group = status, value = optimal_stock)
 
 per_route <- farm_movements %>% 
   filter(from != 0) %>% 
   group_by(from, to) %>% 
   summarise(weight = n()) %>% 
   ungroup()
 
 edges <- per_route
 
 
 visNetwork(nodes, edges)
 

#Plot a count of farm statuses per day

farm_transmissions %>% 
  filter(date != "0-01-01") %>% 
  group_by(date, status) %>% 
  summarise(status_count = n()) %>% 
  pivot_wider(names_from = status, values_from = status_count) %>% 
  mutate(perc_resistant = `2`/(`1`+`2`)) %>% 
  mutate(perc_sensitive = `1`/(`1`+`2`)) %>% 
  plot_ly(x = ~date) %>% 
    add_trace(y = ~perc_resistant,  mode = 'lines+markers', name = "Resistant") %>% 
    add_trace(y = ~perc_sensitive,  mode = 'lines+markers', name = "Sensitive") %>% 
  layout(
    xaxis = list(title = "Date"),
    yaxis = list(title = "Proportion of farms resistant (n = 250)"),
    title = "Proportion of resistant farms over time"
  )
 

tmp <- farm_transmissions %>% 
  filter(date != "0-01-01") %>% 
  group_by(date, status) %>% 
  summarise(status_count = n())

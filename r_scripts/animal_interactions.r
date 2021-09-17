interactions <- read_csv("./export/seasonal_contacts.csv")

contacts <- interactions %>%
                filter(agent_stage == "C") %>%
                filter(contact_id != "No contact") %>%
                filter(Day != 0) %>%
                mutate(Day = lubridate::ymd(Day)) %>%
                filter(Day >= min(Day) & Day <= "2021-07-08") %>%
                select(Day, agent_id, contact_id, contact_stage) %>%
                distinct(Day, agent_id, contact_id, contact_stage) %>%
                mutate(across(everything(), as.character))

sources <- contacts %>%
  distinct(agent_id) %>%
  rename(label = agent_id) 

destinations <- contacts %>%
  distinct(contact_id) %>%
  rename(label = contact_id)

nodes <- full_join(sources, destinations, by = "label")

nodes <- nodes %>% rowid_to_column("id")
nodes

per_route <- contacts %>%  
  group_by(agent_id, contact_id) %>%
  summarise(weight = n()) %>% 
  ungroup()

edges <- per_route %>% 
  left_join(nodes, by = c("agent_id" = "label")) %>% 
  rename(from = id)

edges <- edges %>% 
  left_join(nodes, by = c("contact_id" = "label")) %>% 
  rename(to = id)

edges <- select(edges, from, to, weight)
edges

library(network)

routes_network <- network(edges, vertex.attr = nodes, matrix.type = "edgelist", ignore.eval = FALSE)

plot(routes_network, vertex.cex = 3)

library(igraph)

routes_igraph <- graph_from_data_frame(d = edges, vertices = nodes, directed = TRUE)

library(networkD3)

nodes_d3 <- mutate(nodes, id = id - 1)
edges_d3 <- mutate(edges, from = from - 1, to = to - 1)

forceNetwork(Links = edges_d3, Nodes = nodes_d3, Source = "from", Target = "to", 
             NodeID = "label", Group = "id", Value = "weight", 
             opacity = 1, fontSize = 16, zoom = TRUE)

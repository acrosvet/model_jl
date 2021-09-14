source("./r_scripts/libraries.r")

# Seasonal ---------------------------------------------------------------

initial_positions <- read_csv("./export/seasonal_initial_positions.csv")

initial_positions <- initial_positions %>%
                        mutate(label = 
                        case_when(
                            z == 5 ~"Milkers",
                            z == 4 ~"Preg. Heifers",
                            z == 2 ~"Weaned",
                            z == 1 ~"Calves",
                            z == 3 ~"Heifers",
                            z == 6 ~"Dry"))

p <- plot_ly(initial_positions) %>%
    add_trace(x=~x, y=~y, z=~z, color = ~label) %>%
    layout(
  title = "Initial agent positions (seasonal)")

  htmlwidgets::saveWidget(p, "./export/Initial Agent Positions (Seasonal).html", selfcontained = F, libdir = "lib")

# Split ---------------------------------------------------------------

initial_positions <- read_csv("./export/split_initial_positions.csv")

initial_positions <- initial_positions %>%
                        mutate(label = 
                        case_when(
                            z == 5 ~"Milkers",
                            z == 4 ~"Preg. Heifers",
                            z == 2 ~"Weaned",
                            z == 1 ~"Calves",
                            z == 3 ~"Heifers",
                            z == 6 ~"Dry"))

p <- plot_ly(initial_positions) %>%
    add_trace(x=~x, y=~y, z=~z, color = ~label) %>%
    layout(
  title = "Initial agent positions (split)")

  htmlwidgets::saveWidget(p, "./export/Initial Agent Positions (Split).html", selfcontained = F, libdir = "lib")

  # Batch ---------------------------------------------------------------

initial_positions <- read_csv("./export/batch_initial_positions.csv")

initial_positions <- initial_positions %>%
                        mutate(label = 
                        case_when(
                            z == 5 ~"Milkers",
                            z == 4 ~"Preg. Heifers",
                            z == 2 ~"Weaned",
                            z == 1 ~"Calves",
                            z == 3 ~"Heifers",
                            z == 6 ~"Dry"))

p <- plot_ly(initial_positions) %>%
    add_trace(x=~x, y=~y, z=~z, color = ~label) %>%
    layout(
  title = "Initial agent positions (batch)")

  htmlwidgets::saveWidget(p, "./export/Initial Agent Positions (Batch).html", selfcontained = F, libdir = "lib")


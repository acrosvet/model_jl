source("./r_scripts/libraries.r")

initial_positions <- read_csv("./export/initial_positions.csv")

initial_positions <- initial_positions %>%
                        mutate(label = 
                        case_when(
                            z == 5 ~"Milkers",
                            z == 4 ~"Heifers",
                            z == 2 ~"Weaned"))

p <- plot_ly(initial_positions) %>%
    add_trace(x=~x, y=~y, z=~z, color = ~label) %>%
    layout(
  title = "Initial agent positions (seasonal)")

  htmlwidgets::saveWidget(p, "./export/Initial Agent Positions.html", selfcontained = F, libdir = "lib")

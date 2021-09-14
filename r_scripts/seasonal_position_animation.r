source("./r_scripts/libraries.r")

pos_data <- read_csv("./export/seasonal_positions.csv")

plot_ly(pos_data) %>%
    add_trace(x=~x, 
    y=~y, 
    z=~z, 
    color = ~stage) %>%
    layout(
  title = "Initial agent positions (batch)")

fig <- pos_data %>%
slice(1:25000) %>%
filter(step != 0) %>%
  plot_ly(
    x = ~x,
    y = ~y,
    z = ~z,
    type = 'scatter3d',
    mode = 'markers',
    frame = ~Day,
    marker = list(size = 5),
    showlegend = F, 
    color = ~stage)

fig

  htmlwidgets::saveWidget(fig, "./export/Seasonal position animation.html", selfcontained = F, libdir = "lib")

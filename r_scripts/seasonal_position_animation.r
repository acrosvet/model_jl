source("./r_scripts/libraries.r")

pos_data <- read_csv("./export/seasonal_positions.csv")

plot_ly(pos_data) %>%
    add_trace(x=~x, 
    y=~y, 
    z=~z, 
    color = ~label) %>%
    layout(
  title = "Initial agent positions (batch)")

fig <- pos_data %>%
filter(step != 0) %>%
  plot_ly(
    x = ~y,
    y = ~z,
    z = ~stage,
    frame = ~step,
    type = 'scatter',
    mode = 'markers',
    showlegend = F, 
    color = ~x)

fig

source("./r_scripts/libraries.r")

pos_data <- read_csv("./export/seasonal_positions.csv")

# Investigate Day 81

day_81 <- pos_data %>%
            group_by(Day, stage) %>%
            summarise(count = n()) %>%
            pivot_wider(names_from = stage, values_from = count)

plot_ly(pos_data) %>%
    add_trace(x=~x, 
    y=~y, 
    z=~z, 
    color = ~stage) %>%
    layout(
  title = "Initial agent positions (batch)")

fig <- pos_data %>%
slice(1:51000) %>%
filter(step != 0) %>%
  plot_ly(
    x = ~x,
    y = ~y,
    z = ~z,
    type = 'scatter3d',
    frame = ~step,
    text = c("\U1F404"),
    textfont = list(size = 15),
    mode = 'text',
    color = ~stage) %>%
  layout(
    title = "Animal movements over time",
    scene = list(
    xaxis = list(
      range=c(0,63)
    ),
    yaxis = list(
      range = c(0,63)
    ),
    zaxis = list(
      range = c(0,8)
    )
  ))

fig

  htmlwidgets::saveWidget(fig, "./export/Seasonal position animation.html", selfcontained = F, libdir = "lib")

# View agent movements -------------------------------------------------------

# Calves

position_animation <- function(stage){
pos_data %>%
  filter(Day != 0) %>%
  filter(stage == !!stage) %>%
  plot_ly(
    x = ~x,
    y = ~y,
    type = 'scatter',
    text = c("\U1F404"),
    textfont = list(size = 25, color = 'green'),
    mode = 'text',
    #marker = list(size = 5),
    frame = ~Day
  ) 
}

position_animation("L")

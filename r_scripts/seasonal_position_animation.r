source("./r_scripts/libraries.r")

pos_data <- read_csv("./export/seasonal_positions.csv")

# Investigate Day 81

day_81 <- pos_data %>%
            group_by(Day, stage) %>%
            summarise(count = n()) %>%
            pivot_wider(names_from = stage, values_from = count)

tmp = pos_data %>% 
  filter(stage == "L")

fig <- plot_ly(pos_data) %>%
    filter(step ==1) %>%
    add_trace(x=~x, 
    y=~y, 
    z=~z, 
    color = ~stage) %>%
    layout(
  title = "Initial agent positions")

fig <- pos_data %>%
#slice(1:51000) %>%
filter(step != 0) %>%
  plot_ly(
    x = ~x,
    y = ~y,
    z = ~z,
    type = 'scatter3d',
    frame = ~step,
    text = c("\U1F404"),
    textfont = list(size = 20),
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
          if (stage == "L") {
          label =   "lactating cows."}
          else if (stage == "C") {
            label = "calves."}
          else if (stage == "D") {
            label = "dry cows."}
          else if (stage == "W") {
            label = "weaned animals."}
          else if (stage == "DH") {
            label = "preg. heifers."}
          else if (stage == "H") {
            label = "heifers."}
          
pos_data %>%
  #slice(1:51000) %>%
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
    frame = ~Day) %>%
    layout(title = paste0("Positions for ", label))
}

fig <- position_animation("C")

htmlwidgets::saveWidget(fig, "./export/Seasonal calf positions.html", selfcontained = F, libdir = "lib")

fig <- position_animation("L")

  htmlwidgets::saveWidget(fig, "./export/Seasonal cow positions.html", selfcontained = F, libdir = "lib")

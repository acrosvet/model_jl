source("./r_scripts/libraries.r")

positions <- read_csv("./export/bacterial_positions.csv")

positions %>%
    filter(bactostatus != 0) %>%
    arrange(step, id) %>%
    plot_ly(x = ~x, y = ~y, color = ~strain, colors = 'Dark2', frame = ~step)

positions %>%
    filter(step != 0) %>%
    group_by(step, bactostatus) %>%
    summarise(count = n()) %>%
    pivot_wider(names_from = bactostatus, values_from = count) %>%
    plot_ly(x = ~step) %>%
    add_trace(y = ~IS, name = "IS") %>%
    add_trace(y = ~S, name = "Susceptible") %>%
    add_trace(y = ~R, name = "Resistant")

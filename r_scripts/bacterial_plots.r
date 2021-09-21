source("./r_scripts/libraries.r")

positions <- read_csv("./export/bacterial_positions.csv")

positions %>%
    filter(bactostatus != 0) %>%
    arrange(id) %>%
    plot_ly(x = ~x, y = ~y, color = ~bactostatus, colors = 'Dark2', frame = ~step)

positions %>%
    filter(step != 0) %>%
    group_by(step, bactostatus) %>%
    summarise(count = n()) %>%
    pivot_wider(names_from = bactostatus, values_from = count) %>%
    plot_ly(x = ~step) %>%
    add_trace(y = ~S, name = "Susceptible") %>%
    add_trace(y = ~IS, name = "Resistant")


bacto_run <- read_csv("./export/bacterial_model_run.csv")

source("./r_scripts/libraries.r")

positions <- read_csv("./export/bacterial_positions.csv")

scratch <- positions %>%
    group_by(step, bactostatus) %>%
    summarise(count = n()) %>%
    pivot_wider(names_from = bactostatus, values_from = count)

p <- positions %>%
    filter(bactostatus != 0) %>%
    #arrange(id) %>%
    plot_ly(x = ~x, y = ~y, color = ~bactostatus, colors = 'Dark2', frame = ~step) %>%
    animation_opts(redraw = T, transition = 0)

process <- positions %>% 
            filter(bactostatus != 0) %>%
            select(x,y,bactostatus,step)

process <- as.matrix(process)

plot_ly(z = process, colors = "Greys", type = "heatmap")

  htmlwidgets::saveWidget(p, "./export/Bacterial Positions.html", selfcontained = F, libdir = "lib")


positions %>%
    filter(bactostatus != 0) %>%
    arrange(id) %>%
    plot_ly(x = ~x, y = ~y, color = ~strain, colors = 'Dark2', frame = ~step) %>%
    animation_opts(redraw = FALSE, transition = 0)



positions %>%
    filter(step != 0) %>%
    group_by(step, bactostatus) %>%
    summarise(count = n()) %>%
    pivot_wider(names_from = bactostatus, values_from = count) %>%
    plot_ly(x = ~step) %>%
    add_trace(y = ~S, name = "Susceptible") %>%
    add_trace(y = ~R, name = "Resistant")


bacto_run <- read_csv("./export/bacterial_model_run.csv")

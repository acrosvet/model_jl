source("./r_scripts/libraries.r")

positions <- read_csv("./export/bacterial_positions.csv")

scratch <- positions %>%
    filter(id != 0) %>%
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





  htmlwidgets::saveWidget(p, "./export/Bacterial Positions.html", selfcontained = F, libdir = "lib")

p <- positions %>%
    filter(step != 0) %>%
    #filter(step == 1) %>%
    ggplot(aes(x = x, y = y, fill = bactostatus)) +
    geom_tile() +
    transition_states(step, transition_length = 0, state_length = 1) +
    theme_void()+    
    ggtitle('Model day {frame}')



library(gganimate)
animate(p)

p <-  p 

anim_save("./export/animation.gif")
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

View(bacto_run %>%
    arrange(animal_id, step))

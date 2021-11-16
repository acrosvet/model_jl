time_positions <-    ggplot(positions %>% group_by(id,x,y), aes(x = x, y = y, color = bactostatus)) +
        geom_point(show.legend = TRUE) +
        transition_time(step) +
        ease_aes('linear')

animate(time_positions, renderer=gifski_renderer())
anim_save("./export/bactoanim.gif",animation = last_animation(), renderer = gifski_renderer())



movement <- positions %>%
    group_by(id) %>%
    summarise(unique_x = length(unique(x)), unique_y = length(unique(y)))
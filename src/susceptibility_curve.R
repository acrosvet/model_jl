cvals = rep(0, 1825)
dr = seq(1:1825)

for(i in 1:1825){
    cvals[i] = 100*(exp(1)^(-4500/i)/0.5)
}

library(ggplot2)

val_df = tibble(
    day = dr,
    value = cvals
)

val_df %>% 
    ggplot(aes(x = day, y = value)) +
    geom_line() + 
    theme_minimal() +
    xlab("Days since recovery") +
    ylab("Percentage of standard susceptibility") +
    ggtitle("Return to susceptibility in recovered stock")

ggsave("./export/plots/susceptibility_curve.png")

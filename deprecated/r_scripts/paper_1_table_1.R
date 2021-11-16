source("./r_scripts/libraries.r")

table_one <- read_csv("./r_scripts/data/table_one.csv")

table_one %>%
    kableExtra::kable(format = "latex")

table_two <- read_csv("./r_scripts/data/table_one.csv")

table_two %>%
    kableExtra::kable(format = "latex")


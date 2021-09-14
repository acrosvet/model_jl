pos_data = DataFrame(
    stage = AnimalAgent.stage,
    x = AnimalAgent.pos[1],
    y = AnimalAgent.pos[2],
    z = AnimalAgent.pos[3]
)
pos_output = open("./export/seasonal_model_run.csv","a")
CSV.write(pos_output, pos_data, delim = ",", append = true, header = false)
close(output)

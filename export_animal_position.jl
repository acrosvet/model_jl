function export_animal_position!(AnimalAgent, animalModel)
pos_data = DataFrame(
    step = animalModel.step,
    stage = AnimalAgent.stage,
    x = AnimalAgent.pos[1],
    y = AnimalAgent.pos[2],
    z = AnimalAgent.pos[3]
)
pos_output = open("./export/seasonal_positions.csv","a")
CSV.write(pos_output, pos_data, delim = ",", append = true, header = false)
close(pos_output)
end
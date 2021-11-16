function export_culling!(AnimalAgent, animalModel, culling_reason)
    culling_data = DataFrame(
        step = animalModel.step,
        Day = animalModel.date,
        culled_id = AnimalAgent.id,
        age = AnimalAgent.age,
        pregstat = AnimalAgent.pregstat,
        dim = AnimalAgent.dim,
        dic = AnimalAgent.dic,
        reason = culling_reason)
    culling_output = open("./export/seasonal_culling.csv","a")
    CSV.write(culling_output, culling_data, delim = ",", append = true, header = false)
    close(culling_output)
    end
tmp = initialiseModel(50)


header = DataFrame(
    FarmID = 0,
    Day = 0,
    AnimalID = 0,
    AnimalStatus = 0,
    AnimalStage = 0,
    DaysInfected = 0,
    DaysExposed = 0,
    DaysCarrier = 0,
    AnimalTreatment = 0,
    DaysTreated = 0,
    DaysSinceTreatment = 0,
    DaysDry = 0,
    TradeStatus = 0,
    AnimalBactoPop = 0,
    ModelYear = 0,
)

output = open("./export/farm_$farm_id-animal_model_run.csv","w")
    CSV.write(output, header, delim = ",", append = true, header = true)
    close(output)

step!(tmp, agent_step!, model_step!, 10*365)
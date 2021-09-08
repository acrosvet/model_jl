tmp = initialiseModel(50)


header = DataFrame(
    ModelStep = 0,
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
    AnimalAge = 0,
    AgentType = 0,
    DIM = 0,
    PregStat = 0
)

output = open("./export/animal_model_run.csv","w")
    CSV.write(output, header, delim = ",", append = true, header = true)
    close(output)

run!(tmp, agent_step!, model_step!, 365*25)

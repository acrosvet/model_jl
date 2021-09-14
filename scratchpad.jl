tmp = initialiseSeasonal(220)


header = DataFrame(
    Day = 0,
    ModelStep = 0,
    FarmID = 0,
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
    AnimalAge = 0,
    AgentType = 0,
    DIM = 0,
    PregStat = 0,
    dic = 0,
    psc = 0,
    msd = 0,
    CurrentLac = 0,
)

output = open("./export/seasonal_model_run.csv","w")
    CSV.write(output, header, delim = ",", append = true, header = true)
    close(output)

pos_header = DataFrame(
    x = 0,
    y = 0,
    z = 0,
    stage = 0,
)

pos_output = open("./export/seasonal_positions.csv","w")
    CSV.write(pos_output, pos_header, delim = ",", append = true, header = true)
close(pos_output)

run!(tmp, agent_step!, model_step!, 365*25)

step!(tmp, agent_step!, model_step!) 
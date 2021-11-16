tmp = initialiseSplit(220)


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
    CalvingSeason = 0,
    SpringLac = 0,
    CurrentSpring = 0,
    AutumnLac = 0,
    CurrentAutumn = 0,
)

output = open("./export/split_model_run.csv","w")
    CSV.write(output, header, delim = ",", append = true, header = true)
    close(output)

run!(tmp, agent_step!, model_step!, 365*25)

step!(tmp, agent_step!, model_step!)
function export_animal_data!(AnimalAgent, animalModel)

data = DataFrame(
    Day = animalModel.date,
    ModelStep = animalModel.step,
    FarmID = animalModel.farm_id,
    AnimalID = AnimalAgent.id,
    AnimalStatus = AnimalAgent.status,
    AnimalStage = AnimalAgent.stage,
    DaysInfected = AnimalAgent.inf_days,
    DaysExposed = AnimalAgent.days_exposed,
    DaysCarrier = AnimalAgent.days_carrier,
    AnimalTreatment = AnimalAgent.treatment,
    DaysTreated = AnimalAgent.days_treated,
    DaysSinceTreatment = AnimalAgent.since_tx,
    DaysDry = AnimalAgent.days_dry,
    TradeStatus = AnimalAgent.trade_status,
    AnimalBactoPop = AnimalAgent.bactopop,
    AnimalAge = AnimalAgent.age,
    AgentType = AnimalAgent.agenttype,
    DIM = AnimalAgent.dim,
    PregStat = AnimalAgent.pregstat,
    dic = AnimalAgent.dic,
    psc = animalModel.psc,
    msd = animalModel.msd,
    CurrentLac = animalModel.current_lac,
    CalvingSeason = AnimalAgent.calving_season,
    SpringLac = animalModel.lac_spring,
    CurrentSpring = animalModel.current_spring,
    AutumnLac = animalModel.lac_autumn,
    CurrentAutumn = animalModel.current_autumn
)

if animalModel.system == :Seasonal
output = open("./export/seasonal_model_run.csv","a")
    CSV.write(output, data, delim = ",", append = true, header = false)
    close(output)
elseif animalModel.system == :Split
    output = open("./export/split_model_run.csv","a")
    CSV.write(output, data, delim = ",", append = true, header = false)
    close(output)
elseif animalModel.system == :Batch
    output = open("./export/batch_model_run.csv","a")
    CSV.write(output, data, delim = ",", append = true, header = false)
    close(output)
end
end
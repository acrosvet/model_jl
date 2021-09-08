function export_animal_data!(AnimalAgent, animalModel)

data = DataFrame(
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
    ModelYear = animalModel.model_year,
    AnimalAge = AnimalAgent.age,
    AgentType = AnimalAgent.agenttype,
    DIM = AnimalAgent.dim,
    PregStat = AnimalAgent.pregstat,
    dic = AnimalAgent.dic,
    psc = AnimalAgent.psc,
    msd = AnimalAgent.msd,
)


output = open("./export/animal_model_run.csv","a")
    CSV.write(output, data, delim = ",", append = true, header = false)
    close(output)

end
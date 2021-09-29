function export_animal_data!(AnimalAgent, animalModel)
    if animalModel.system == :Seasonal
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
            AnimalBactoPop_r = AnimalAgent.bactopop_r,
            AnimalBactoPop_is = AnimalAgent.bactopop_is,
            AnimalAge = AnimalAgent.age,
            AgentType = AnimalAgent.agenttype,
            DIM = AnimalAgent.dim,
            PregStat = AnimalAgent.pregstat,
            dic = AnimalAgent.dic,
            psc = animalModel.psc,
            msd = animalModel.msd,
            CurrentLac = animalModel.current_lac,
            CalvingSeason = AnimalAgent.calving_season
    
        )
elseif animalModel.system == :Split
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
        AnimalBactoPop_r = AnimalAgent.bactopop_r,
        AnimalBactoPop_is = AnimalAgent.bactopop_is,
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
elseif animalModel.system == :Batch
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
        AnimalBactoPop_r = AnimalAgent.bactopop_r,
        AnimalBactoPop_is = AnimalAgent.bactopop_is,
        AnimalAge = AnimalAgent.age,
        AgentType = AnimalAgent.agenttype,
        DIM = AnimalAgent.dim,
        PregStat = AnimalAgent.pregstat,
        dic = AnimalAgent.dic,
        psc_2 = animalModel.psc_2,
        msd_2 = animalModel.msd_2,
        CurrentLac = animalModel.current_lac,
        CalvingSeason = AnimalAgent.calving_season
    )
elseif animalModel.system == :Continuous
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
            AnimalBactoPop_r = AnimalAgent.bactopop_r,
            AnimalBactoPop_is = AnimalAgent.bactopop_is,
            AnimalAge = AnimalAgent.age,
            AgentType = AnimalAgent.agenttype,
            DIM = AnimalAgent.dim,
            PregStat = AnimalAgent.pregstat,
            dic = AnimalAgent.dic
    
        )
end 

# Differetial output by system type -------------------------------------
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
    elseif animalModel.system == :Continuous
        output = open("./export/continuous_model_run.csv","a")
        CSV.write(output, data, delim = ",", append = true, header = false)
        close(output)
    end
end
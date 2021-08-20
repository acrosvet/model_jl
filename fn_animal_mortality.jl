function mortality!(AnimalAgent, animalModel)
    if AnimalAgent.status == :IS && (rand(animalModel.rng) < animalModel.mortalityRateSens)
    kill_agent!(AnimalAgent, animalModel)
    else 
    AnimalAgent.inf_days_is += 1*time_resolution
    end

    if AnimalAgent.status == :IR && (rand(animalModel.rng) < animalModel.mortalityRateRes)
        kill_agent!(AnimalAgent, animalModel)
    else
        AnimalAgent.inf_days_ir += 1*time_resolution
    end

    # Cull agent -------------------------------

    if AnimalAgent.stage == :L && (0.3/365 > rand(animalModel.rng))
        kill_agent!(AnimalAgent, animalModel)
    else
        return
    end

end

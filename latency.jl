function latency!(AnimalAgent, animalModel)

    latent_period = rand(animalModel.rng, 1:3)

    if AnimalAgent.days_exposed ≥ latent_period
        if AnimalAgent.status == :ES 
            AnimalAgent.status = :IS 
            AnimalAgent.days_exposed = 0
            AnimalAgent.inf_days += 1
        elseif AnimalAgent.status == :ER
            AnimalAgent.status = :IR
            AnimalAgent.days_exposed = 0
            AnimalAgent.inf_days += 1
        end
    end
end
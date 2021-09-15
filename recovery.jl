function recovery!(AnimalAgent, animalModel)

recovery_time = rand(7:10)   

if AnimalAgent.inf_days ≥ recovery_time
    if AnimalAgent.status == :IS && AnimalAgent.treatment == :U
        if rand(animalModel.rng) > 0.03
            AnimalAgent.status = :recovered
            AnimalAgent.inf_days = 0
        else 
            AnimalAgent.status = :carrier_sensitive
            AnimalAgent.inf_days = 0
            AnimalAgent.days_carrier += 1
        end
    elseif AnimalAgent.status == :IR && AnimalAgent.treatment == :U
        if rand(animalModel.rng) > 0.03
            AnimalAgent.status = :recovered
            AnimalAgent.inf_days = 0
        else 
            AnimalAgent.status = :carrier_resistant
            AnimalAgent.inf_days = 0
            AnimalAgent.days_carrier += 1
        end
    end


end
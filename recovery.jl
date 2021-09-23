function recovery!(AnimalAgent, animalModel)

recovery_time = rand(animalModel.rng, 5:7)   

# Make recovered

if AnimalAgent.inf_days ≥ recovery_time
    if AnimalAgent.status == :IS
        if rand(animalModel.rng) > animalModel.sens_carrier
            AnimalAgent.status = :recovered
            AnimalAgent.inf_days = 0
            AnimalAgent.days_recovered += 1
        else
            AnimalAgent.status = :CS
            AnimalAgent.inf_days = 0
            AnimalAgent.days_recovered += 1
        end
    elseif AnimalAgent.status == :IR
        if rand(animalModel.rng) > animalModel.res_carrier
            AnimalAgent.status = :recovered
            AnimalAgent.inf_days = 0
            AnimalAgent.days_recovered += 1
        else
            AnimalAgent.status = :CR
            AnimalAgent.inf_days = 0
            AnimalAgent.days_recovered += 1
        end
    end
end


end
function recovery!(AnimalAgent, animalModel)

recovery_time = rand(animalModel.rng, 5:7)   

# Make recovered

if AnimalAgent.treatment == :T
    AnimalAgent.days_treated += 1
end

if AnimalAgent.status == :IS || AnimalAgent.status == :IR
    if rand(animalModel.rng) < 0.5
        AnimalAgent.days_treated = 1
        AnimalAgent.treatment = :T
    end
end

if AnimalAgent.days_treated > rand(animalModel.rng,3:5)
    AnimalAgent.treatment = :P
    AnimalAgent.status = :recovered
    AnimalAgent.days_treated = 0
end

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
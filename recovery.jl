function recovery!(AnimalAgent, animalModel)

recovery_time = rand(7:10)   

# Make recovered

if AnimalAgent.inf_days ≥ recovery_time
    if AnimalAgent.status == :IS
        if rand(animalModel.rng) > animalModel.sens_carrier
            AnimalAgent.status = :recovered
            AnimalAgent.inf_days = 0
            AnimalAgent.days_recovered += 1
        else 
            AnimalAgent.status = :carrier_sensitive
            AnimalAgent.inf_days = 0
            AnimalAgent.days_carrier += 1
        end
    elseif AnimalAgent.status == :IR
        if rand(animalModel.rng) > animalModel.res_carrier
            AnimalAgent.status = :recovered
            AnimalAgent.inf_days = 0
            AnimalAgent.days_recovered += 1
        else 
            AnimalAgent.status = :carrier_resistant
            AnimalAgent.inf_days = 0
            AnimalAgent.days_carrier += 1
        end
    end
end
    # Wane immunity back to susceptible

if AnimalAgent.status == :recovered && AnimalAgent.days_recovered ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(45), 30, 60))))
        AnimalAgent.status = :S
        AnimalAgent.days_recovered = 0
end


end
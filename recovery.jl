function recovery!(AnimalAgent, animalModel)

# Determine a recovery time, animals may start to recover between 5 and 7 days after the onset of infectiousness
recovery_time = rand(animalModel.rng, 5:7)   



# If the number of days infected exceeds the recovery time, the animal recovers, but remains infectious as it clears the bacteria. 
if AnimalAgent.inf_days ≥ recovery_time
    if AnimalAgent.status == :IS 
        if rand(animalModel.rng) > animalModel.sens_carrier
            AnimalAgent.status = :RS
            AnimalAgent.inf_days = 0
            AnimalAgent.days_recovered = 1
        else
        #Animals may become carriers at the parametrised rate.
            AnimalAgent.status = :CS
            AnimalAgent.inf_days = 0
            AnimalAgent.days_recovered = 1
            AnimalAgent.days_carrier = 0
        end
    elseif AnimalAgent.status == :IR
        if rand(animalModel.rng) > animalModel.res_carrier
            AnimalAgent.status = :RR
            AnimalAgent.inf_days = 0
            AnimalAgent.days_recovered = 1
        else
            AnimalAgent.status = :CR
            AnimalAgent.inf_days = 0
            AnimalAgent.days_recovered = 1
            AnimalAgent.days_carrier = 0 
        end
    end
end

end
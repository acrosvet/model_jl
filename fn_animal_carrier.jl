function carrierState!(AnimalAgent, animalModel)
    
    # Some calves enter a carrier state
    if (AnimalAgent.status == :RR || AnimalAgent.status == :RS) && AnimalAgent.treatment == :PT
        if rand(animalModel.rng) < animalModel.res_carrier
            AnimalAgent.status = :CR
        end
    end

    if AnimalAgent.status == :RS
        if rand(animalModel.rng) < animalModel.sens_carrier
            AnimalAgent.status = :CS
        end
    end
end


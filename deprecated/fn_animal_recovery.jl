# Fn - Recovery ------------------------------------------------------    

function recover!(AnimalAgent, animalModel)
    if (AnimalAgent.inf_days ≥ 5*time_resolution && AnimalAgent.status == :IS) && (rand(animalModel.rng) < animalModel.sponrec_is)
        AnimalAgent.status = :RS
    elseif AnimalAgent.inf_days ≥ 5*time_resolution && AnimalAgent.status == :IR && (rand(animalModel.rng) < animalModel.sponrec_ir)
        AnimalAgent.status = :RR
    end
end
